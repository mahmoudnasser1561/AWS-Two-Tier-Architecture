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
  ec2_sg_id          = module.compute.ec2_sg_id
  backup_retention_period = 14
  db_username       = var.db_username
  db_password       = var.db_password
}

module "compute" {
  source            = "./modules/compute"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids 
  alb_sg_id         = module.alb.alb_sg_id
  my_ip             = var.MY_IP
  public_key_path   = var.public_key_path
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
  target_id        = module.compute.instance1_id  
}

resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.two_tier_tg.arn
  target_id        = module.compute.instance2_id  
  port             = 80
}
