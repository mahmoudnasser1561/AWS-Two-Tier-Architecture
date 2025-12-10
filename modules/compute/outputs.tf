output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.two_tier_sg.id
}

output "asg_name" {
  value = aws_autoscaling_group.two_tier_asg.name
}