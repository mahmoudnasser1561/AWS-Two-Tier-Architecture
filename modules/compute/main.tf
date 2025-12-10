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
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
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

resource "aws_launch_template" "two_tier_lt" {
  name_prefix   = "two-tier-lt-"
  image_id      = data.aws_ssm_parameter.two-tier-ami.value
  instance_type = "t2.micro"
  key_name      = aws_key_pair.two_tier_key.key_name

  vpc_security_group_ids = [aws_security_group.two_tier_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
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
  vpc_zone_identifier = var.public_subnet_ids  

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