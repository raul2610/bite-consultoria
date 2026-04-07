# módulo: database
# RDS instance (PostgreSQL por defecto) y/o ElastiCache Redis cluster.

# ── DB Subnet Group ───────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  count = var.create_rds ? 1 : 0

  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = { Name = "${var.name}-db-subnet-group" }
}

# ── RDS Security Group ────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  count = var.create_rds ? 1 : 0

  name        = "${var.name}-rds-sg"
  description = "Allow DB access from application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB port from app"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-rds-sg" }
}

# ── RDS Instance ──────────────────────────────────────────────────────────────
resource "aws_db_instance" "this" {
  count = var.create_rds ? 1 : 0

  identifier        = "${var.name}-db"
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  multi_az            = var.db_multi_az
  skip_final_snapshot = true
  storage_encrypted   = true

  tags = { Name = "${var.name}-db" }
}

# ── ElastiCache Subnet Group ──────────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "this" {
  count = var.create_elasticache ? 1 : 0

  name       = "${var.name}-cache-subnet-group"
  subnet_ids = var.subnet_ids
}

# ── ElastiCache Security Group ────────────────────────────────────────────────
resource "aws_security_group" "cache" {
  count = var.create_elasticache ? 1 : 0

  name        = "${var.name}-cache-sg"
  description = "Allow Redis access from application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis port from app"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-cache-sg" }
}

# ── ElastiCache Replication Group (Redis) ─────────────────────────────────────
resource "aws_elasticache_replication_group" "this" {
  count = var.create_elasticache ? 1 : 0

  replication_group_id = "${var.name}-redis"
  description          = "Redis cache for ${var.name}"

  node_type            = var.cache_node_type
  num_cache_clusters   = var.cache_num_nodes
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this[0].name
  security_group_ids = [aws_security_group.cache[0].id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = { Name = "${var.name}-redis" }
}
