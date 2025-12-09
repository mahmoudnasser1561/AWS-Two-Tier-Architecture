output "lb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.two-tier-lb.arn
}

output "lb_dns" {
  description = "DNS name of the ALB"
  value       = aws_lb.two-tier-lb.dns_name
}


