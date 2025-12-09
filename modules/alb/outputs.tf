output "lb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.two-tier-lb.arn
}

output "lb_dns" {
  description = "DNS name of the ALB"
  value       = aws_lb.two-tier-lb.dns_name
}

output "ami_id" {
  description = "AMI ID from SSM parameter"
  value       = data.aws_ssm_parameter.two-tier-ami.value
}
