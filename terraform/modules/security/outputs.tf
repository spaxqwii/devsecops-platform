output "waf_arn" {
  description = "WAF Web ACL ARN"
  value       = var.alb_arn != "" ? aws_wafv2_web_acl.this[0].arn : ""
}

output "guardduty_id" {
  description = "GuardDuty Detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : ""
}

output "access_analyzer_arn" {
  description = "Access Analyzer ARN"
  value       = aws_accessanalyzer_analyzer.this.arn
}
