output "PrivateIP" {
  description = "Private IP of EC2 instance 1"
  value       = module.compute.instance1_private_ip
}

output "PrivateIP2" {
  description = "Private IP of EC2 instance 2"
  value       = module.compute.instance2_private_ip
}

output "PublicIP" {
  description = "Public IP of EC2 instance 1"
  value       = module.compute.instance1_public_ip
}

output "PublicIP2" {
  description = "Public IP of EC2 instance 2"
  value       = module.compute.instance2_public_ip
}

output "RDS_Endpoint" {
  value = module.db.db_endpoint
}

output "alb_dns_from_module" {
  value = module.alb.lb_dns
}


