# Experimento 05 – Táctica de Modificabilidad
#
# Objetivo: demostrar tácticas de modificabilidad mediante:
#   - Descomposición en microservicios usando ECS Fargate (cada servicio es independiente)
#   - API Gateway como fachada que permite cambiar servicios sin afectar clientes
#   - Lambda para lógica de negocio sin servidor (deploy sin afectar infraestructura)
#   - Variables de feature flags via SSM Parameter Store

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "bite-consultoria"
      Experiment  = "05-modifiability"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ── Networking ────────────────────────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  name               = "${var.name}-mod"
  vpc_cidr           = var.vpc_cidr
  az_count           = 2
  enable_nat_gateway = true
}

# ── ECS Cluster (microservicios) ──────────────────────────────────────────────
resource "aws_ecs_cluster" "this" {
  name = "${var.name}-mod-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = "${var.name}-mod-cluster" }
}

# ── IAM: ECS Task Execution Role ──────────────────────────────────────────────
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-mod-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ── Security Group: ECS tasks ─────────────────────────────────────────────────
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name}-mod-ecs-sg"
  description = "ECS tasks inbound from API Gateway VPC Link"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-mod-ecs-sg" }
}

# ── Microservice A: users-service ─────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "users" {
  name              = "/ecs/${var.name}/users-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "users" {
  family                   = "${var.name}-users-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "users-service"
    image     = var.users_service_image
    essential = true
    portMappings = [{ containerPort = 8080, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.users.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "users" {
  name            = "${var.name}-users-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.users.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.networking.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

# ── Microservice B: orders-service ────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "orders" {
  name              = "/ecs/${var.name}/orders-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "orders" {
  family                   = "${var.name}-orders-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "orders-service"
    image     = var.orders_service_image
    essential = true
    portMappings = [{ containerPort = 8080, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.orders.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "orders" {
  name            = "${var.name}-orders-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.networking.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

# ── Lambda function (serverless business logic) ───────────────────────────────
resource "aws_iam_role" "lambda" {
  name = "${var.name}-mod-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}-processor"
  retention_in_days = 7
}

resource "aws_lambda_function" "processor" {
  function_name = "${var.name}-processor"
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  image_uri     = var.lambda_image_uri

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]

  tags = { Name = "${var.name}-processor" }
}

# ── API Gateway (HTTP API) ────────────────────────────────────────────────────
resource "aws_apigatewayv2_api" "this" {
  name          = "${var.name}-api"
  protocol_type = "HTTP"

  tags = { Name = "${var.name}-api" }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.processor.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "process" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /process"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# ── SSM Parameters (feature flags) ───────────────────────────────────────────
resource "aws_ssm_parameter" "feature_new_checkout" {
  name  = "/${var.name}/${var.environment}/feature/new_checkout"
  type  = "String"
  value = "false"

  tags = { Name = "${var.name}-feature-new-checkout" }
}
