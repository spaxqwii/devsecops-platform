variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "desired_count" {
  description = "Desired task count"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB"
  type        = number
  default     = 512
}

variable "enable_execute_command" {
  description = "Enable ECS Exec"
  type        = bool
  default     = false
}

variable "secrets_arn" {
  description = "Secrets Manager ARN"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
