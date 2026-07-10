output "waf_arn" {
  description = "WAF Web ACL ARN"
  value       = var.alb_arn != "" ? aws_wafv2_web_acl.this.arn : ""
}

output "access_analyzer_arn" {
  description = "Access Analyzer ARN"
  value       = aws_accessanalyzer_analyzer.this.arn
}
