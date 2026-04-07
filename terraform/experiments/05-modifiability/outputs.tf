output "api_gateway_endpoint" {
  description = "Invoke URL of the API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "lambda_function_name" {
  description = "Name of the Lambda processor function"
  value       = aws_lambda_function.processor.function_name
}

output "feature_flag_parameter_name" {
  description = "SSM parameter name for the new_checkout feature flag"
  value       = aws_ssm_parameter.feature_new_checkout.name
}
