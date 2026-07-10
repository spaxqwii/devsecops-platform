# OPA Policy: Cost Optimization

package main

# Warn: Large EC2 instances
warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    startswith(resource.change.after.instance_type, "t3.large")
    msg := sprintf("Consider smaller instance type for %s", [resource.address])
}

# Deny: Expensive RDS instances
deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.after.instance_class == "db.r6g.xlarge"
    msg := sprintf("RDS instance %s is too expensive for dev", [resource.address])
}

# Warn: Missing lifecycle policies
warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_ecr_repository"
    not resource.change.after.lifecycle_policy
    msg := sprintf("ECR repository %s should have lifecycle policy", [resource.address])
}
