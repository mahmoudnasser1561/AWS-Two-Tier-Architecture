output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.two_tier_sg.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.two_tier_asg.name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}