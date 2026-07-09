# ADR 002: OIDC over Long-Lived AWS Credentials

## Status
Accepted

## Context
GitHub Actions needs AWS credentials to push to ECR and deploy to ECS.

## Decision
Use **OpenID Connect (OIDC)** with `sts:AssumeRoleWithWebIdentity`.

## Consequences

### Positive
- **No secrets to rotate**: No `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` in GitHub.
- **Fine-grained trust**: Role can be restricted to specific repos, branches, and environments.
- **Audit trail**: CloudTrail logs every assumption with GitHub workflow context.
- **Industry standard**: Used by Netflix, Spotify, and AWS's own documentation.

### Negative
- **Initial setup complexity**: Requires creating OIDC provider and trust policy.
- **GitHub dependency**: If GitHub is down, deployments fail.

## Implementation
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:*"
      }
    }
  }]
}
```
