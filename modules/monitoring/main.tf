resource "aws_sns_topic" "asg_notifications" {
  name = "two-tier-asg-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.asg_notifications.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [var.asg_name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.asg_notifications.arn
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "two-tier-asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2AutoScaling"
  period              = 300 
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "Alarm when ASG average CPU exceeds ${var.cpu_high_threshold}%"
  alarm_actions       = [aws_sns_topic.asg_notifications.arn] 

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "two-tier-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100 
  alarm_description   = "Alarm when RDS connections exceed 100"
  alarm_actions       = [aws_sns_topic.asg_notifications.arn]

  dimensions = {
    DBInstanceIdentifier = "two-tier-db" 
  }
}

resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/ec2/two-tier/apache"
  retention_in_days = 14  
}

resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/rds/two-tier/mysql"
  retention_in_days = 14
}