variable "name" {
  description = "Prefix used to name all database resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB and cache subnet groups (use private subnets)"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Security group IDs of the application that is allowed to connect to the databases"
  type        = list(string)
  default     = []
}

# ── RDS variables ─────────────────────────────────────────────────────────────
variable "create_rds" {
  description = "Whether to create an RDS instance"
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "RDS database engine (e.g. postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "15"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the RDS instance (use a secret manager in production)"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Port on which the database listens"
  type        = number
  default     = 5432
}

variable "db_multi_az" {
  description = "Whether to create a Multi-AZ RDS deployment"
  type        = bool
  default     = false
}

# ── ElastiCache variables ─────────────────────────────────────────────────────
variable "create_elasticache" {
  description = "Whether to create an ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "cache_num_nodes" {
  description = "Number of cache nodes in the replication group"
  type        = number
  default     = 1
}
