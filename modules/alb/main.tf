resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = var.vpc_id  

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "two-tier-lb" {
  load_balancer_type         = "application"
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  
  security_groups            = [aws_security_group.alb_sg.id] 
  tags = {
    Name = "TTLB"
  }
}
