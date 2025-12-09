provider "aws" {
  region = var.main_region
}

module "vpc" {
  source = "./modules"
  region = var.main_region
}

resource "aws_key_pair" "two_tier_key" {
  key_name   = "two-tier-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "two_tier_sg" {
  name   = "two-tier-sg"
  vpc_id = module.vpc.vpc_id


  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.MY_IP}/32"]
  }

  ingress {
    description = "HTTP"
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


resource "aws_instance" "two-tier-instance1" {
  ami                         = module.vpc.ami_id
  subnet_id                   = module.vpc.subnet_id1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.two_tier_key.key_name

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.two_tier_sg.id]
}

resource "aws_instance" "two-tier-instance2" {
  ami                         = module.vpc.ami_id
  subnet_id                   = module.vpc.subnet_id2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.two_tier_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.two_tier_sg.id]
}

resource "aws_security_group" "rds_sg" {
  name   = "two-tier-rds-sg"
  vpc_id = module.vpc.vpc_id

  # Allow MySQL (3306) only from the EC2 SG
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.two_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "two_tier_db" {
  name       = "two_tier_db"
  subnet_ids = [module.vpc.subnet_id3, module.vpc.subnet_id4]

  tags = {
    Name = "two_tier_db"
  }
}

resource "aws_db_instance" "two_tier_db" {
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  db_name                 = "two_tier_db"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.two_tier_db.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
}
