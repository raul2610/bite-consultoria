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
  default     = "10.4.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t3.small"
}

# ── ASG variables ─────────────────────────────────────────────────────────────
variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 10
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_target_cpu" {
  description = "Target CPU utilization percentage for ASG target tracking"
  type        = number
  default     = 50
}

# ── ECS variables ─────────────────────────────────────────────────────────────
variable "container_image" {
  description = "Docker image for the ECS task (e.g. nginx:latest)"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the ECS task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MiB for the ECS task"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  type    = number
  default = 2
}

variable "ecs_min_count" {
  type    = number
  default = 1
}

variable "ecs_max_count" {
  type    = number
  default = 10
}

variable "ecs_target_cpu" {
  description = "Target CPU utilization percentage for ECS service auto-scaling"
  type        = number
  default     = 50
}
