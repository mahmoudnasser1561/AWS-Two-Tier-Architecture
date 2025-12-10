output "PrivateIP" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.two-tier-instance1.private_ip
}

output "PrivateIP2" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.two-tier-instance2.private_ip
}

output "PublicIP" {
  description = "Public IP of EC2 instance 1"
  value       = aws_instance.two-tier-instance1.public_ip
}

output "PublicIP2" {
  description = "Public IP of EC2 instance 2"
  value       = aws_instance.two-tier-instance2.public_ip
}

output "RDS_Endpoint" {
  value = module.db.db_endpoint
}

output "alb_dns_from_module" {
  value = module.alb.lb_dns
}


