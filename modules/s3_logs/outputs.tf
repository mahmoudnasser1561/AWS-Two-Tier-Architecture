output "logs_bucket_name" {
    value = aws_s3_bucket.alb_logs.bucket
}