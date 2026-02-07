# Secure & Scalable Two-Tier Web Architecture on AWS with Terraform

[![Terraform Version](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~%205.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Production-grade **two-tier** (web + database) infrastructure deployed entirely with **Terraform** on AWS — highly available, secure, observable, and automated via GitHub Actions with **OIDC authentication**.

Perfect demonstration of real-world cloud engineering skills: modular IaC, least-privilege security, auto-scaling, monitoring, logging, and modern CI/CD practices.

## Architecture Overview

Multi-AZ, secure two-tier web application with:

- VPC with public & private subnets across 2 Availability Zones
- Internet Gateway + NAT Gateway for outbound internet from private subnets
- Application Load Balancer (ALB) + WAF (AWS Managed Rules)
- Auto Scaling Group (ASG) of EC2 instances (t2.micro, Apache httpd)
- Amazon RDS MySQL (Multi-AZ)
- Bastion host in public subnet for secure SSH access
- CloudWatch Logs + Metrics + Alarms + SNS notifications
- Centralized ALB access logs in S3
- Secrets stored in AWS SSM Parameter Store
- GitHub Actions CI/CD pipeline using **AWS IAM OIDC federation**

**High-level diagram**
<img width="2462" height="1290" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/1f02a6e2-7dab-4ae4-9370-871aa4677f80" />



## Key Features & Best Practices Demonstrated

- **Modular Terraform design** — clear separation of concerns (vpc, alb, compute, db, monitoring, s3_logs, waf, iam)
- **Zero-trust networking** — no public access to web servers or database; only ALB and bastion are public-facing
- **Auto Scaling** with target tracking (CPU 50%) + scale-out policy
- **Security hardening**
  - Security Groups with least privilege
  - AWS WAF on ALB
  - IAM roles & instance profiles (no access keys on instances)
  - SSM Parameter Store for database credentials
  - OIDC-based GitHub Actions authentication (no stored AWS secrets)
- **Observability**
  - CloudWatch Agent on EC2 → Apache access/error logs
  - RDS enhanced monitoring & CloudWatch alarms
  - CPU & connection alarms with SNS email notifications
- **CI/CD** — GitHub Actions workflow with plan on PR/push + manual apply/destroy
- **State management** — remote backend in S3

## Project Structure
```
.
├── bootstrap.tf
├── docs
│   ├── graph.svg
│   └── plan.txt
├── main.tf
├── modules
│   ├── alb
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── compute
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── db
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── monitoring
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── s3_logs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── waf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── README.md
└── variables.tf

10 directories, 31 files
```

## Local Deployment
```
terraform init

terraform plan \
  -var="db_username=username" \
  -var="db_password=passwordr" \
  -var="notification_email=you@example.com" \
  -var="my_ip=203.0.113.42/32" \
  -var="public_key_path=~/.ssh/id_rsa.pub"

terraform apply
```

# Outputs 
```
alb_dns_from_module → public URL of application
bastion_public_ip → SSH jump host
RDS_Endpoint → database connection string
github_actions_role_arn → for CI/CD setup
```
