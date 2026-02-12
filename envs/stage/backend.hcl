bucket         = "two-tier-tf-state-bucket-tf"
key            = "envs/stage/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "two-tier-tf-locks"
