output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.this.name
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.this.arn
}
