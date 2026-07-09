variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devsecops"
}

variable "owner_email" {
  description = "Owner email for tagging"
  type        = string
  default     = "devops@example.com"
}

variable "aws_account_id" {
  description = "AWS Account ID for S3 bucket naming"
  type        = string
}

variable "github_org" {
  description = "GitHub organization/username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "devsecops-platform"
}

# ==================== NETWORKING ====================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (costs ~$30/mo)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cheaper, less HA)"
  type        = bool
  default     = true
}

# ==================== ECS ====================
variable "container_image" {
  description = "Container image URI"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:alpine" # Placeholder
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1 # Free tier: keep at 1
}

variable "cpu" {
  description = "CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB"
  type        = number
  default     = 512
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

# ==================== SECURITY ====================
variable "enable_guardduty" {
  description = "Enable GuardDuty (free tier: first 30 days)"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Enable Security Hub (free tier: first 30 days)"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config (free tier: first 1,000 evaluations)"
  type        = bool
  default     = false # Can get expensive; enable with caution
}

# ==================== OBSERVABILITY ====================
variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 1 # Free tier: keep low, delete often
}

# ==================== TAGS ====================
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "devsecops-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
