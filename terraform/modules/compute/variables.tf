variable "name" {
  description = "Prefix used to name all compute resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Custom AMI ID (leave empty to use the latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 8080
}

variable "alb_security_group_ids" {
  description = "Security group IDs of the ALB that is allowed to reach the instances"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach to instances"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Shell script executed at instance launch (plain text)"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}

variable "target_group_arns" {
  description = "List of ALB Target Group ARNs to attach to the ASG"
  type        = list(string)
  default     = []
}
