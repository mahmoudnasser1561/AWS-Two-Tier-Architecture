# AWS-Two-Tier-Architecture

# ARCH 
<img width="1618" height="1752" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/8f2b504d-78db-4945-a508-76e07dba862e" />


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
  
