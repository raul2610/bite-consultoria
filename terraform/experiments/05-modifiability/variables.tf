variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Base name prefix for all resources"
  type        = string
  default     = "bite"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.5.0.0/16"
}

variable "users_service_image" {
  description = "Container image for the users microservice"
  type        = string
  default     = "nginx:latest"
}

variable "orders_service_image" {
  description = "Container image for the orders microservice"
  type        = string
  default     = "nginx:latest"
}

variable "lambda_image_uri" {
  description = "ECR URI for the Lambda container image (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/processor:latest)"
  type        = string
  default     = "public.ecr.aws/lambda/python:3.12"
}
