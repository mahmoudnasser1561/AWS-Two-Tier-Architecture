resource "aws_wafv2_web_acl" "alb_waf" {
  name        = "two-tier-waf"
  scope       = "REGIONAL"  
  default_action {
    allow {}  
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      count {}  
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "two-tier-waf"
    sampled_requests_enabled   = true
  }
  tags = { Name = "TwoTierWAF" }
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}
