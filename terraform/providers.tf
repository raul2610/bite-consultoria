terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure to use a remote backend (S3 + DynamoDB recommended for AWS)
  # backend "s3" {
  #   bucket         = "<your-tfstate-bucket>"
  #   key            = "bite-consultoria/terraform.tfstate"
  #   region         = "<your-region>"
  #   dynamodb_table = "<your-lock-table>"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "bite-consultoria"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
