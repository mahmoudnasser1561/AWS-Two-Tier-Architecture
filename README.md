# AWS-Two-Tier-Architecture

# ARCH 
<img width="1991" height="1290" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/948b4e02-eae0-4ba9-9aa6-817528285889" />


The architecture includes production-grade services such as:
- NAT Gateway
- Application Load Balancer
- RDS Multi-AZ
- WAF
- s3_logs
- cloudwatch alarms
- sns for email notification
- ... ,etc

To avoid unnecessary cloud costs, the project is validated using
`terraform plan`, which completes successfully with no errors.


# TO-DO
- CI/CD with github actions
- OpenID Provider
  
