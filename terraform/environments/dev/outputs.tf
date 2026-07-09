output "app_url" {
  description = "URL of the deployed application"
  value       = "http://${module.ecs.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for CI/CD"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "ARN for GitHub Actions OIDC role"
  value       = aws_iam_role.github_actions.arn
}

output "cloudwatch_dashboard" {
  description = "CloudWatch Dashboard name"
  value       = module.observability.dashboard_name
}

output "security_hub_status" {
  description = "Security Hub enabled status"
  value       = var.enable_securityhub ? "Enabled" : "Disabled"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}
