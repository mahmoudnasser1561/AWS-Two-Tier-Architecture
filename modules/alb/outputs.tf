output "lb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.two-tier-lb.arn
}

output "lb_dns" {
  description = "DNS name of the ALB"
  value       = aws_lb.two-tier-lb.dns_name
}

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}
