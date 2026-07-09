# Runbook: High CPU Alert

## Alert
`devsecops-dev-high-cpu` fires when ECS CPU utilization > 80% for 10 minutes.

## Immediate Actions

### 1. Verify Alert
```bash
aws cloudwatch get-metric-statistics   --namespace AWS/ECS   --metric-name CPUUtilization   --dimensions Name=ClusterName,Value=devsecops-dev-cluster                Name=ServiceName,Value=devsecops-dev-service   --start-time $(date -u -d '20 minutes ago' +%Y-%m-%dT%H:%M:%SZ)   --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)   --period 60   --statistics Average
```

### 2. Check Application Logs
```bash
aws logs tail /ecs/devsecops-dev-app --since 20m
```

### 3. Identify Cause

| Pattern | Likely Cause | Action |
|---------|-------------|--------|
| Gradual increase | Normal load growth | Scale up service |
| Sudden spike | Traffic surge or attack | Check WAF logs, rate limit |
| Sustained high | Inefficient code | Profile application |
| Periodic spikes | Cron job or batch | Adjust scheduling |

### 4. Scale Up (Emergency)
```bash
aws ecs update-service   --cluster devsecops-dev-cluster   --service devsecops-dev-service   --desired-count 3
```

### 5. Scale Down (After Resolution)
```bash
aws ecs update-service   --cluster devsecops-dev-cluster   --service devsecops-dev-service   --desired-count 1
```

## Prevention
- Set up auto-scaling policies
- Review application performance
- Implement caching layer
- Optimize database queries
