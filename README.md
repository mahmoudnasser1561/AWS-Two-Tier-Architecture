# AWS-Two-Tier-Architecture

# ARCH 
<img width="1617" height="1371" alt="new_updated_Arch drawio" src="https://github.com/user-attachments/assets/bc3d3f08-96b8-4af0-b189-adfd3f11579e" />


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
  
