terraform {
  backend "s3" {
    bucket               = "two-tier-tf-state-bucket-tf" 
    key                  = "terraform.tfstate" 
    region               = "us-east-1"
    encrypt              = true  
    skip_credentials_validation = true 
  }
}

provider "aws" {
  region = var.main_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids = module.vpc.alb_public_subnet_ids 
  private_subnet_ids = module.vpc.db_private_subnet_ids 
  logs_bucket_name  = module.s3_logs.logs_bucket_name
}

module "db" {
  source            = "./modules/db"
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.db_private_subnet_ids  
  ec2_sg_id          = module.compute.ec2_sg_id
  backup_retention_period = 14
  db_username       = var.db_username
  db_password       = var.db_password
}

module "compute" {
  source            = "./modules/compute"
  vpc_id            = module.vpc.vpc_id
  web_private_subnet_ids = module.vpc.web_private_subnet_ids 
  my_ip             = var.MY_IP
  public_key_path   = var.public_key_path
  target_group_arn  = module.alb.target_group_arn  
  bastion_subnet_id = module.vpc.bastion_public_subnet_id
  alb_sg_id = module.alb.alb_sg_id
}

module "monitoring" {
  source = "./modules/monitoring"

  asg_name        = module.compute.asg_name
  email_address   = var.notification_email
}

module "waf" {
  source   = "./modules/waf"
  alb_arn  = module.alb.lb_arn  
}

module "s3_logs" {
  source   = "./modules/s3_logs"
  alb_arn  = module.alb.lb_arn
}