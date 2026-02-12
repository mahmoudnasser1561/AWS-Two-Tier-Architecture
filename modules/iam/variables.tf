variable "project_name" {
  description = "Project prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name for resource naming"
  type        = string
}

variable "alb_logs_bucket_arn" {
  description = "ARN of the ALB logs bucket"
  type        = string
}
