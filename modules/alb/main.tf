resource "aws_lb" "two-tier-lb" {
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "TTLB"
  }
}

data "aws_ssm_parameter" "two-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
