# OPA Policy: Security Best Practices for Terraform
# Run with: conftest test terraform/ -p terraform/policies/

package main

#import future.keywords.if
#import future.keywords.in

# Deny: S3 buckets without encryption
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}

# Deny: Security groups with 0.0.0.0/0 on SSH
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    rule := resource.change.after.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 22
    rule.to_port >= 22
    msg := sprintf("Security group %s allows SSH from 0.0.0.0/0", [resource.address])
}

# Deny: IAM policies with wildcard actions
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role_policy"
    statement := resource.change.after.policy.Statement[_]
    statement.Action[_] == "*"
    msg := sprintf("IAM policy %s uses wildcard action", [resource.address])
}

# Deny: Resources without tags
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type != "random_id"
    not resource.change.after.tags
    msg := sprintf("Resource %s must have tags", [resource.address])
}

# Deny: ECS tasks running as root
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_ecs_task_definition"
    container := resource.change.after.container_definitions[_]
    container.user == "0"
    msg := sprintf("ECS task %s must not run as root", [resource.address])
}

# Deny: CloudWatch logs without retention
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudwatch_log_group"
    not resource.change.after.retention_in_days
    msg := sprintf("CloudWatch log group %s must have retention policy", [resource.address])
}

# Warn: NAT Gateway in single AZ
warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_nat_gateway"
    msg := "NAT Gateway should be deployed in multiple AZs for HA"
}
