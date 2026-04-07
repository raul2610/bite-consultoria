# Experimento 02 – Táctica de Rendimiento
#
# Objetivo: demostrar tácticas de rendimiento mediante:
#   - Application Load Balancer (distribución de carga)
#   - ElastiCache Redis (caché en memoria)
#   - CloudFront (CDN para contenido estático)
#   - Auto Scaling Group para escalar según demanda

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
      Experiment  = "02-performance"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ── Networking ────────────────────────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  name               = "${var.name}-perf"
  vpc_cidr           = var.vpc_cidr
  az_count           = 2
  enable_nat_gateway = true
}

# ── ALB Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Allow inbound HTTP"
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
    path     = "/health"
    interval = 15
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

  name                   = "${var.name}-perf"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  instance_type          = var.instance_type
  alb_security_group_ids = [aws_security_group.alb.id]
  target_group_arns      = [aws_lb_target_group.this.arn]
  min_size               = 2
  max_size               = 6
  desired_capacity       = 2
}

# ── ElastiCache Redis (caching) ───────────────────────────────────────────────
module "database" {
  source = "../../modules/database"

  name                   = "${var.name}-perf"
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  app_security_group_ids = [module.compute.instance_security_group_id]
  create_elasticache     = true
  cache_node_type        = var.cache_node_type
  cache_num_nodes        = 2
}

# ── CloudFront Distribution (CDN) ─────────────────────────────────────────────
resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = "${var.name} CDN"

  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "${var.name}-cf" }
}
