# AWS-Two-Tier-Architecture

# ARCH 
<img width="2215" height="1290" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/58524913-07bc-4077-8709-b97539a17807" />


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
  
