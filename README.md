# DevSecOps Platform — Production-Grade Reference Architecture

> **Free Tier Safe** | **Spin up → Learn → Destroy** | **Real-world patterns**

A complete DevSecOps platform built on AWS Free Tier, demonstrating modern infrastructure, security, observability, and GitOps practices used daily by platform engineers.

---

## What This Builds

| Layer | What | Tools |
|-------|------|-------|
| **Network** | VPC with public/private subnets, NAT, flow logs | Terraform |
| **Compute** | ECS Fargate (serverless containers) | Terraform |
| **CI/CD** | GitHub Actions → ECR → ECS deployment | GitHub Actions |
| **Security** | Trivy scanning, OPA policies, Secrets Manager, GuardDuty | Trivy, OPA, AWS |
| **Observability** | CloudWatch Logs, Metrics, Alarms, X-Ray | AWS Native |
| **GitOps** | ArgoCD-style pattern with GitHub Actions | GitHub Actions |
| **Platform** | Internal developer portal concept | Backstage-ready structure |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      VPC (10.0.0.0/16)                 │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │   │
│  │  │  Public     │  │  Public     │  │   Private       │  │   │
│  │  │  Subnet A   │  │  Subnet B   │  │   Subnet A      │  │   │
│  │  │  (ALB)      │  │  (NAT GW)   │  │   (ECS Fargate) │  │   │
│  │  └──────┬──────┘  └─────────────┘  └─────────────────┘  │   │
│  │         │                                                  │   │
│  │    ┌────┴────┐    ┌─────────────┐    ┌─────────────┐      │   │
│  │    │   ALB   │───▶│  WAFv2      │───▶│ CloudWatch  │      │   │
│  │    │(HTTPS)  │    │ (Rate Limit)│    │ Logs/Metrics│      │   │
│  │    └────┬────┘    └─────────────┘    └─────────────┘      │   │
│  │         │                                                  │   │
│  │    ┌────┴────────────────────────────────────────────┐     │   │
│  │    │              ECS Fargate Service                 │     │   │
│  │    │  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │     │   │
│  │    │  │  App Container│  │  X-Ray Sidecar│  │  Envoy  │ │     │   │
│  │    │  │  (Node.js)   │  │  (Tracing)   │  │ (Mesh)  │ │     │   │
│  │    │  └─────────────┘  └─────────────┘  └─────────┘ │     │   │
│  │    └──────────────────────────────────────────────────┘     │   │
│  │                           │                                │   │
│  │                    ┌──────┴──────┐                          │   │
│  │                    │ Secrets Mgr │                          │   │
│  │                    │  (DB creds) │                          │   │
│  │                    └─────────────┘                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Security: GuardDuty │ Config │ SecurityHub │ IAM Analyzer│   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

GitHub Actions Pipeline:
PR ──▶ Lint ──▶ SAST (Semgrep) ──▶ Build ──▶ Trivy Scan ──▶ Push ECR ──▶ Deploy ECS
```

---

## Project Structure

```
├── terraform/              # All infrastructure as code
│   ├── modules/             # Reusable modules
│   │   ├── vpc/             # Network layer
│   │   ├── ecs/             # Container orchestration
│   │   ├── security/        # WAF, GuardDuty, SecurityHub
│   │   └── observability/   # CloudWatch, X-Ray, alarms
│   ├── environments/
│   │   └── dev/             # Free tier dev environment
│   └── policies/            # OPA/Rego policies
├── app/                     # Sample microservice (Node.js)
├── .github/
│   └── workflows/           # CI/CD pipelines
├── scripts/
│   ├── setup.sh             # One-command deploy
│   └── destroy.sh           # Clean teardown (preserves credits)
└── docs/
    ├── runbooks/            # Incident response templates
    └── adr/                 # Architecture Decision Records
```

---

## Quick Start

### 1. Prerequisites

```bash
# Install tools
brew install terraform awscli gh trivy opa  # macOS
# or
sudo apt install terraform awscli  # Linux

# Configure AWS (Free Tier account)
aws configure  # Use IAM user with programmatic access

# Login to GitHub CLI
gh auth login
```

### 2. Deploy Everything

```bash
# Clone and enter
gh repo clone YOUR_USERNAME/devsecops-platform
cd devsecops-platform

# One-command deploy
./scripts/setup.sh
```

### 3. Verify

```bash
# Get the application URL
terraform -chdir=terraform/environments/dev output app_url

# Check security findings
aws securityhub get-findings --max-items 5

# View CloudWatch dashboard
aws cloudwatch get-dashboard --dashboard-name devsecops-platform
```

### 4. Destroy (Critical for Free Tier!)

```bash
./scripts/destroy.sh
```

---

## Cost Estimate (Free Tier Monthly)

| Service | Free Tier Allowance | This Project | Status |
|---------|-------------------|--------------|--------|
| ECS Fargate | 750 hrs vCPU + 750 GB RAM | ~200 hrs | ✅ Safe |
| ALB | 750 hrs + 15 LCUs | ~200 hrs | ✅ Safe |
| CloudWatch | 10 metrics, 5GB logs | ~2GB | ✅ Safe |
| ECR | 500MB storage | ~100MB | ✅ Safe |
| VPC | No charge | NAT Gateway ~$30/mo | ⚠️ See note |

> **NAT Gateway costs ~$30/month.** For true free tier, use the `single_nat_gateway = false` flag in `terraform.tfvars` — this places ECS tasks in public subnets (acceptable for learning, not production).

---

## Learning Path

| Week | Focus | Hands-On |
|------|-------|----------|
| 1 | Terraform & AWS Foundations | Build VPC, ECS, ALB. Understand state, modules, workspaces |
| 2 | Security & Compliance | Implement OPA policies, Trivy scanning, Secrets Manager rotation |
| 3 | Observability | Build CloudWatch dashboards, set up alarms, trace with X-Ray |
| 4 | GitOps & Platform | Build GitHub Actions pipeline, document ADRs, create runbooks |

---

## Key Design Decisions

See [`docs/adr/`](docs/adr/) for full Architecture Decision Records.

1. **ECS Fargate over EKS** — No control plane costs, simpler operations, sufficient for learning
2. **AWS Native observability** — CloudWatch is free-tier eligible; Prometheus/Grafana would require EC2
3. **GitHub Actions over Jenkins** — Managed, free for public repos, integrates with AWS OIDC
4. **OPA over Sentinel** — Open source, works across cloud providers, industry standard

---

## Teardown Checklist

Before your AWS bill arrives:

- [ ] Run `./scripts/destroy.sh`
- [ ] Verify empty ECR repositories
- [ ] Check CloudWatch log groups deleted
- [ ] Confirm no lingering ENIs or volumes

---

## Contributing

This is a learning project. Break things, fix them, document what you learned in `docs/lessons-learned/`.

---

**License:** MIT | **Status:** Ready for deployment | **Last verified:** July 2026
