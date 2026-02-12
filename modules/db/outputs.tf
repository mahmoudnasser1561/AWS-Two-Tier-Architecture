output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.two_tier_db.endpoint
}

output "db_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.two_tier_db.identifier
}
