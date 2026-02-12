# Secure Two-Tier AWS Architecture with Terraform

[![Terraform Version](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~%206.25-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Terraform project that provisions a two-tier web architecture on AWS:
- Web tier: private EC2 Auto Scaling Group behind an internet-facing ALB
- Data tier: private Multi-AZ RDS MySQL
- Supporting components: WAF, CloudWatch alarms/logs, S3 ALB access logs, OIDC-based CI role

## Architecture Summary
- VPC across two Availability Zones with public and private subnets
- Single NAT Gateway for private-subnet egress (intentional cost/HA tradeoff)
- Application Load Balancer (HTTP) with target group health checks
- EC2 Launch Template + Auto Scaling Group for Apache web tier
- RDS MySQL 8.0 (Multi-AZ, encrypted storage, backups, final snapshot enabled)
- AWS WAF attached to ALB (AWS Managed Common Rule Set in blocking mode)
- CloudWatch alarms for ASG CPU and RDS connections + SNS notifications
- ALB access logs in hardened S3 bucket

**High-level diagram**  
<img width="2462" height="1290" alt="architecture diagram" src="https://github.com/user-attachments/assets/1f02a6e2-7dab-4ae4-9370-871aa4677f80" />

## Intentional Tradeoffs
- Single NAT Gateway: lower cost, lower egress high availability.
- HTTP only on ALB: no domain/ACM cert yet, so TLS termination is deferred.

## Security Controls Implemented
- Security groups enforce tier boundaries:
  - ALB accepts public HTTP
  - App instances accept HTTP only from ALB SG
  - RDS accepts MySQL only from app SG
  - Bastion SSH limited to a single CIDR (`my_ip`)
- RDS storage encryption enabled
- WAF attached and enforcing managed rules
- S3 hardening for logs/state buckets:
  - public access block
  - ownership controls
  - server-side encryption (AES256)
  - lifecycle rules
- OIDC trust for GitHub Actions role (no long-lived AWS access keys in CI)

## Observability
- CloudWatch log groups for app and RDS logs
- CloudWatch alarms:
  - high ASG CPU
  - high RDS database connections
- SNS notifications for Auto Scaling events and alarms
- ALB access logging to S3

## Repository Structure
```text
.
├── bootstrap/
│   ├── main.tf
│   └── variables.tf
├── envs/
│   ├── dev/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   ├── stage/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   └── prod/
│       ├── backend.hcl
│       └── terraform.tfvars
├── .github/workflows/cicd.yaml
├── modules/
│   ├── vpc/
│   ├── alb/
│   ├── compute/
│   ├── db/
│   ├── monitoring/
│   ├── waf/
│   ├── s3_logs/
│   └── iam/
├── docs/
├── main.tf
├── variables.tf
├── versions.tf
└── outputs.tf
```

## State and Environments
- `bootstrap/` provisions remote state backend resources (S3 + DynamoDB lock table).
- `envs/dev|stage|prod/backend.hcl` defines state key per environment.
- `envs/dev|stage|prod/terraform.tfvars` defines non-secret environment settings.
- Sensitive values (`db_username`, `db_password`) are passed from CLI or CI secrets.

## Deployment
1. Create backend resources:
```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

2. Deploy an environment (example: dev):
```bash
terraform init -backend-config=envs/dev/backend.hcl
terraform plan \
  -var-file=envs/dev/terraform.tfvars \
  -var="db_username=<db_username>" \
  -var="db_password=<db_password>"
terraform apply \
  -var-file=envs/dev/terraform.tfvars \
  -var="db_username=<db_username>" \
  -var="db_password=<db_password>"
```

3. Destroy:
```bash
terraform destroy \
  -var-file=envs/dev/terraform.tfvars \
  -var="db_username=<db_username>" \
  -var="db_password=<db_password>"
```

## CI/CD
- GitHub Actions workflow: `.github/workflows/cicd.yaml`
- Auth: AWS IAM OIDC role assumption
- Flow:
  - push / PR: `init` + `validate` + `plan`
  - manual dispatch: `plan`, `apply`, or `destroy` with selected environment


## Outputs
```text
alb_dns_from_module    -> public URL of application
bastion_public_ip      -> bastion host public IP
RDS_Endpoint           -> database endpoint
github_actions_role_arn -> IAM role ARN for GitHub Actions
```
