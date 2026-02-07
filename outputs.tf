output "RDS_Endpoint" {
  value = module.db.db_endpoint
}

output "alb_dns_from_module" {
  value = module.alb.lb_dns
}

output "github_actions_role_arn" {
  value       = module.iam.github_actions_role_arn
  description = "ARN of the GitHub Actions IAM role"
}