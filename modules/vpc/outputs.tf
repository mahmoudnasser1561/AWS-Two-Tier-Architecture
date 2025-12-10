output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.two-tier-vpc.id
}

output "alb_public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  value       = [aws_subnet.alb_pub1.id, aws_subnet.alb_pub2.id]
}

output "web_private_subnet_ids" {
  description = "List of private subnet IDs for web/ASG"
  value       = [aws_subnet.web_priv1.id, aws_subnet.web_priv2.id]
}

output "db_private_subnet_ids" {
  description = "List of private subnet IDs for DB"
  value       = [aws_subnet.db_priv1.id, aws_subnet.db_priv2.id]
}

output "bastion_public_subnet_id" {
  description = "Public subnet ID for Bastion and NAT"
  value       = aws_subnet.bastion_pub.id
}