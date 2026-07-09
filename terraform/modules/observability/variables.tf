variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS Service name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix"
  type        = string
}

variable "enable_xray" {
  description = "Enable X-Ray"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
