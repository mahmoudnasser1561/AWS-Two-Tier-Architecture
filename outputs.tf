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

output "bastion_public_ip" {
  value = module.compute.bastion_public_ip
  description = "SSH jump host for Bastion"
}