# Runbook: ECS Task Failed to Start

## Symptoms
- ECS service shows tasks in `PENDING` or `STOPPED` state
- ALB target group shows unhealthy targets
- Application URL returns 502/503

## Diagnostic Steps

### 1. Check Task Status
```bash
aws ecs describe-services   --cluster devsecops-dev-cluster   --services devsecops-dev-service   --query 'services[0].events[:5]'
```

### 2. Check Task Logs
```bash
aws logs tail /ecs/devsecops-dev-app --follow
```

### 3. Check Task Definition
```bash
aws ecs describe-task-definition   --task-definition devsecops-dev-app   --query 'taskDefinition.containerDefinitions[0]'
```

### 4. Check IAM Permissions
```bash
aws iam simulate-principal-policy   --policy-source-arn arn:aws:iam::ACCOUNT:role/devsecops-dev-ecs-execution   --action-names secretsmanager:GetSecretValue   --resource-arns arn:aws:secretsmanager:REGION:ACCOUNT:secret:devsecops-dev-app-secrets
```

## Common Causes

| Cause | Fix |
|-------|-----|
| Image not found in ECR | Verify CI/CD pushed image; check ECR lifecycle policy |
| Secrets Manager access denied | Add `secretsmanager:GetSecretValue` to execution role |
| Out of memory | Increase `memory` in task definition |
| Health check failing | Verify `/health` endpoint responds with 200 |
| Security group blocking ALB | Allow ingress from ALB security group on container port |

## Escalation
If issue persists > 30 minutes:
1. Post in #incidents Slack channel
2. Page on-call engineer if customer-facing
