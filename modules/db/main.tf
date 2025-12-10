resource "aws_security_group" "rds_sg" {
  name        = "two-tier-rds-sg"
  vpc_id      = var.vpc_id 

  # Allow Postgres (5432) only from the EC2 SG
  ingress {
    description     = "Allow Postgres from EC2 SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
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
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "two_tier_db"
  }
}


resource "aws_ssm_parameter" "db_username" {
  name  = "/db/username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/db/password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/db/name"
  type  = "String"
  value = "two_tier_db" 
}

resource "aws_db_instance" "two_tier_db" {
  allocated_storage       = 10
  engine                  = "postgres"
  engine_version          = "14.7"
  instance_class          = "db.t2.micro"

  db_name                 = "two_tier_db"
  identifier              = "two-tier-db"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.two_tier_db.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  backup_retention_period = var.backup_retention_period
  parameter_group_name    = "default.postgres14"
  skip_final_snapshot     = true
  multi_az = true
}

