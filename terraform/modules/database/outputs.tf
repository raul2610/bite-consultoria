output "rds_endpoint" {
  description = "Connection endpoint of the RDS instance"
  value       = var.create_rds ? aws_db_instance.this[0].endpoint : null
}

output "rds_db_name" {
  description = "Name of the default database"
  value       = var.create_rds ? aws_db_instance.this[0].db_name : null
}

output "elasticache_primary_endpoint" {
  description = "Primary endpoint of the ElastiCache Redis replication group"
  value       = var.create_elasticache ? aws_elasticache_replication_group.this[0].primary_endpoint_address : null
}
