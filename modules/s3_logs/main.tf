resource "aws_s3_bucket" "alb_logs" {
  bucket = "two-tier-alb-logs-bucket" 
  tags   = { Name = "ALB Access Logs" }
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["s3:PutObject"]
      Resource  = "${aws_s3_bucket.alb_logs.arn}/*"
      Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
    }, {
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["s3:GetBucketAcl"]
      Resource  = aws_s3_bucket.alb_logs.arn
    }]
  })
}
