output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.two_tier_db.endpoint
}