data "aws_ssm_parameter" "two-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "two_tier_key" {
  key_name   = "two-tier-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "two_tier_sg" {
  name   = "two-tier-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.two-tier-ami.value
  instance_type               = "t2.micro"
  subnet_id                   = var.bastion_subnet_id
  key_name                    = aws_key_pair.two_tier_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
}

resource "aws_iam_role" "ec2_role" {
  name = "two-tier-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "rds:DescribeDBInstances"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "two_tier_lt" {
  name_prefix = "two-tier-lt-"
  image_id = data.aws_ssm_parameter.two-tier-ami.value
  instance_type = "t2.micro"
  key_name = aws_key_pair.two_tier_key.key_name
  vpc_security_group_ids = [aws_security_group.two_tier_sg.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd php php-pgsql awscli
    systemctl start httpd
    systemctl enable httpd
    # Fetch RDS details at runtime
    REGION="us-east-1"
    DB_IDENTIFIER="two-tier-db"
    ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_IDENTIFIER --query "DBInstances[0].Endpoint.Address" --output text --region $REGION)
    DB_NAME=$(aws ssm get-parameter --name /db/name --query "Parameter.Value" --output text --region $REGION)
    USER=$(aws ssm get-parameter --name /db/username --query "Parameter.Value" --output text --region $REGION)
    PASS=$(aws ssm get-parameter --name /db/password --with-decryption --query "Parameter.Value" --output text --region $REGION)
    cat <<PHP_EOF > /var/www/html/index.php
    <?php
    \$servername = "$ENDPOINT";
    \$username = "$USER";
    \$password = "$PASS";
    \$dbname = "$DB_NAME";
    try {
        \$conn = new PDO("pgsql:host=\$servername;dbname=\$dbname", \$username, \$password, [PDO::ATTR_PERSISTENT => true]);
        \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "Connected successfully to the database!<br>";
    } catch(PDOException \$e) {
        echo "Connection failed: " . \$e->getMessage();
    }
?>
    PHP_EOF
    chown -R apache:apache /var/www/html
    EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "two_tier_asg" {
  name                = "two-tier-asg"
  min_size            = 2
  max_size            = 4  
  desired_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = var.web_private_subnet_ids 

  launch_template {
    id      = aws_launch_template.two_tier_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]  

  tag {
    key                 = "Name"
    value               = "two-tier-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.two_tier_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0  
  }
}