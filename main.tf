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
  target_group_arn  = module.alb.target_group_arn  
}



