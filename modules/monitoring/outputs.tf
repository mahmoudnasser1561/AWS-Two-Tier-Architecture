output "sns_topic_arn" {
  value = aws_sns_topic.asg_notifications.arn
}