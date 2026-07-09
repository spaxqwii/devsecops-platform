# Security Module - Defense in depth for AWS

# WAFv2 Web ACL (rate limiting, SQL injection protection)
resource "aws_wafv2_web_acl" "this" {


  name        = "${var.name_prefix}-waf"
  description = "WAF rules for ${var.name_prefix}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rules - Common Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rate Limiting - 2000 requests per 5 minutes per IP
  rule {
    name     = "RateLimit"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection Protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "this" {

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# GuardDuty (Threat Detection)
resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false # Not using EKS
      }
    }
  }

  tags = var.tags
}

# Security Hub (Centralized security findings)
resource "aws_securityhub_account" "this" {
  count = var.enable_securityhub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_securityhub ? 1 : 0

  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "foundational" {
  count = var.enable_securityhub ? 1 : 0

  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

# AWS Config (Compliance monitoring)
resource "aws_config_configuration_recorder" "this" {
  count = var.enable_config ? 1 : 0

  name     = "${var.name_prefix}-config"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_config ? 1 : 0

  name           = "${var.name_prefix}-config"
  s3_bucket_name = aws_s3_bucket.config[0].bucket
  depends_on     = [aws_config_configuration_recorder.this]
}

resource "aws_s3_bucket" "config" {
  count = var.enable_config ? 1 : 0

  bucket_prefix = "${var.name_prefix}-config-"
  force_destroy = true

  tags = var.tags
}

resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0

  name = "${var.name_prefix}-config"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  count = var.enable_config ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# IAM Access Analyzer
resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "${var.name_prefix}-analyzer"
  type          = "ACCOUNT"

  tags = var.tags
}

data "aws_region" "current" {}
