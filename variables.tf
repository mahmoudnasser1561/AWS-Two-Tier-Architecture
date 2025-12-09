variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "db_password" {
  description = "RDS user password"
  sensitive   = true
}

variable "db_username" {
  description = "RDS username"
  sensitive   = true
}

variable "MY_IP" {
  description = "My Machine IP"
  default = "#.#.#.#"
}
