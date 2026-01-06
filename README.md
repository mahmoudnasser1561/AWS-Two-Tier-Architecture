# AWS-Two-Tier-Architecture

# ARCH 
<img width="1617" height="1290" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/56ef0f4e-395b-4c9a-a7a1-a24a269cb9bc" />


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
- monitoring with cloudwatch extended to prometheus - > Grafana
  
