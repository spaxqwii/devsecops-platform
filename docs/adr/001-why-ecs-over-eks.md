# ADR 001: ECS Fargate over EKS

## Status
Accepted

## Context
We need a container orchestration platform for the DevSecOps learning project. Options:
- Amazon EKS (Kubernetes)
- Amazon ECS with Fargate
- Self-managed EC2 with Docker

## Decision
Use **ECS Fargate**.

## Consequences

### Positive
- **No control plane costs**: EKS charges $0.10/hour ($72/month) for the control plane. ECS has no control plane fee.
- **Simpler operations**: No node management, patching, or capacity planning.
- **Faster learning curve**: Focus on DevSecOps practices, not Kubernetes internals.
- **Fargate Spot**: Built-in cost optimization with automatic fallback.

### Negative
- **Less portable**: ECS is AWS-specific. Skills don't transfer directly to GKE/AKS.
- **Limited customization**: No DaemonSets, limited sidecar patterns.
- **Vendor lock-in**: Harder to migrate to another cloud.

## Alternatives Considered

| Option | Cost | Complexity | Learning Value |
|--------|------|-----------|----------------|
| EKS | $72/mo + nodes | High | High (K8s skills) |
| ECS EC2 | Node costs | Medium | Medium |
| ECS Fargate | Pay per use | Low | High (AWS-native) |

## Notes
If the user later wants Kubernetes experience, we can add an EKS module as an optional extension. For now, ECS Fargate provides the best cost-to-learning ratio.
