output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.two_tier_sg.id
}

output "instance1_id" {
  description = "ID of the first EC2 instance"
  value       = aws_instance.two-tier-instance1.id
}

output "instance2_id" {
  description = "ID of the second EC2 instance"
  value       = aws_instance.two-tier-instance2.id
}

output "instance1_private_ip" {
  description = "Private IP of the first EC2 instance"
  value       = aws_instance.two-tier-instance1.private_ip
}

output "instance2_private_ip" {
  description = "Private IP of the second EC2 instance"
  value       = aws_instance.two-tier-instance2.private_ip
}

output "instance1_public_ip" {
  description = "Public IP of the first EC2 instance"
  value       = aws_instance.two-tier-instance1.public_ip
}

output "instance2_public_ip" {
  description = "Public IP of the second EC2 instance"
  value       = aws_instance.two-tier-instance2.public_ip
}