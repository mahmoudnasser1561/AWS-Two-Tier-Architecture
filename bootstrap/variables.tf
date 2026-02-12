variable "aws_region" {
  description = "Region where state bucket and lock table are created"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state"
  type        = string
  default     = "two-tier-tf-state-bucket-tf"
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "two-tier-tf-locks"
}
