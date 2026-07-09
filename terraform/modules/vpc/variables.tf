variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Create IAM role for Flow Logs"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Create CloudWatch Log Group for Flow Logs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
