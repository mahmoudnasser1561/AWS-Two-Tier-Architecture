output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.two-tier-vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.two-tier-subnet-public-1.id, aws_subnet.two-tier-subnet-public-2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.two-tier-subnet-private-1.id, aws_subnet.two-tier-subnet-private-2.id]
}

output "subnet_id1" {
  description = "ID of public subnet 1"
  value       = aws_subnet.two-tier-subnet-public-1.id
}

output "subnet_id2" {
  description = "ID of public subnet 2"
  value       = aws_subnet.two-tier-subnet-public-2.id
}

output "subnet_id3" {
  description = "ID of private subnet 1"
  value       = aws_subnet.two-tier-subnet-private-1.id
}

output "subnet_id4" {
  description = "ID of private subnet 2"
  value       = aws_subnet.two-tier-subnet-private-2.id
}
