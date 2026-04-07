output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "elasticache_primary_endpoint" {
  description = "Primary endpoint of the Redis cluster"
  value       = module.database.elasticache_primary_endpoint
}
