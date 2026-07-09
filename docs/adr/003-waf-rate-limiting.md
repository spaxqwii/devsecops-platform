# ADR 003: WAF Rate Limiting and Managed Rules

## Status
Accepted

## Context
The ALB is internet-facing. We need protection against common attacks without managing our own WAF infrastructure.

## Decision
Use **AWS WAFv2 with managed rule sets**.

## Rules Applied
1. **AWS Managed Rules - Common Rule Set**: SQLi, XSS, LFI, RFI protection
2. **Rate Limiting**: 2000 requests per 5 minutes per IP
3. **AWS Managed Rules - SQLi Rule Set**: Additional SQL injection protection

## Cost
- WAF Web ACL: $5/month
- Rule sets: ~$1/month per rule set
- Requests: $0.60 per million requests
- **Total estimate**: ~$7-10/month for low traffic

## Alternative: CloudFront + WAF
CloudFront provides additional DDoS protection and caching, but adds:
- CloudFront distribution cost
- Data transfer out charges
- Complexity

For a learning project, ALB + WAF is sufficient.
