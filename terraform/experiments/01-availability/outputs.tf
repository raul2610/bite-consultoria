output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the Multi-AZ RDS instance"
  value       = module.database.rds_endpoint
}
