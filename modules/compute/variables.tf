variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the instances"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of the ALB security group (for ingress to EC2 SG)"
  type        = string
}

variable "my_ip" {
  description = "My IP address for SSH access"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type = string
}