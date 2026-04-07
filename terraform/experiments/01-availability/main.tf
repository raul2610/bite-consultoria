# Experimento 01 – Táctica de Disponibilidad
#
# Objetivo: demostrar tácticas de disponibilidad mediante:
#   - Multi-AZ VPC (subnets en 2+ AZs)
#   - Application Load Balancer con health checks
#   - Auto Scaling Group que reemplaza instancias no saludables
#   - RDS Multi-AZ con failover automático

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
      Experiment  = "01-availability"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ── Networking ────────────────────────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  name               = "${var.name}-avail"
  vpc_cidr           = var.vpc_cidr
  az_count           = 2
  enable_nat_gateway = true
}

# ── ALB Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Allow inbound HTTP/HTTPS"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-alb-sg" }
}

# ── Application Load Balancer ─────────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.networking.public_subnet_ids

  tags = { Name = "${var.name}-alb" }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# ── Compute (ASG) ─────────────────────────────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  name                   = "${var.name}-avail"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  instance_type          = var.instance_type
  alb_security_group_ids = [aws_security_group.alb.id]
  target_group_arns      = [aws_lb_target_group.this.arn]
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2

  user_data = <<-EOF
    #!/bin/bash
    yum install -y python3
    python3 -m http.server 8080 &
  EOF
}

# ── RDS Multi-AZ ─────────────────────────────────────────────────────────────
module "database" {
  source = "../../modules/database"

  name                   = "${var.name}-avail"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  app_security_group_ids = [module.compute.instance_security_group_id]
  create_rds             = true
  db_multi_az            = true
  db_password            = var.db_password
}
