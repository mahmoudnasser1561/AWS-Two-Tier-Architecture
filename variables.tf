variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  description = "Project prefix used for naming resources"
  type        = string
  default     = "two-tier"
}

variable "environment" {
  description = "Environment name (for example: dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "RDS user password"
  sensitive   = true
}

variable "db_username" {
  description = "RDS username"
  sensitive   = true
}

variable "my_ip" {
  description = "CIDR block allowed SSH access to bastion (example: 203.0.113.42/32)"
  type        = string
  default     = "156.199.83.23/32"
}

variable "public_key_path" {
  default = "/home/mahmoud/.ssh/prod.pub"
}

variable "notification_email" {
  description = "email address for ASG notifications"
  type        = string
}
