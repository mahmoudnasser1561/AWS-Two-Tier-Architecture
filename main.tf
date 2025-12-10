provider "aws" {
  region = var.main_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
}

module "db" {
  source            = "./modules/db"
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids 
  ec2_sg_id         = aws_security_group.two_tier_sg.id
  db_username       = var.db_username
  db_password       = var.db_password
}

data "aws_ssm_parameter" "two-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "two_tier_key" {
  key_name   = "two-tier-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "two_tier_sg" {
  name   = "two-tier-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "SSH from my IP"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.MY_IP}/32"]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "two_tier_tg" {
  name     = "two-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

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
  load_balancer_arn = module.alb.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.two_tier_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.two_tier_tg.arn
  target_id        = aws_instance.two-tier-instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.two_tier_tg.arn
  target_id        = aws_instance.two-tier-instance2.id
  port             = 80
}

resource "aws_instance" "two-tier-instance1" {
  ami                         = data.aws_ssm_parameter.two-tier-ami.value
  subnet_id                   = module.vpc.subnet_id1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.two_tier_key.key_name

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.two_tier_sg.id]
}

resource "aws_instance" "two-tier-instance2" {
  ami                         = data.aws_ssm_parameter.two-tier-ami.value
  subnet_id                   = module.vpc.subnet_id2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.two_tier_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.two_tier_sg.id]
}
