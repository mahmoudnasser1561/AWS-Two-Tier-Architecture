resource "aws_lb" "two-tier-lb" {
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "TTLB"
  }
}


