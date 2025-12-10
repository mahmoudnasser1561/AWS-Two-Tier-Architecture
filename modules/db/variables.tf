variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "ec2_sg_id" {
  description = "ID of the EC2 security group (to allow ingress to RDS)"
  type        = string
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "The number of days to retain automated backups."
}

variable "db_username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}