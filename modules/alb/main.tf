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

resource "aws_lb_target_group" "two-tier-tg" {
  name     = "two-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.two-tier-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.two-tier-tg.arn 
  }
}