variable "asg_name" {
  description = "Name of the Auto Scaling Group to attach notifications to"
  type        = string
}

variable "email_address" {
  description = "Email address to receive notifications"
  type        = string
}

variable "cpu_high_threshold" {
  type        = number
  default     = 70 
  description = "CPU threshold for high utilization alarm"
}