resource "aws_vpc" "two-tier-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TTVPC"
  }
}

resource "aws_subnet" "two-tier-subnet-public-1" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Pub1"
  }
}

resource "aws_subnet" "two-tier-subnet-public-2" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Pub2"
  }
}

resource "aws_subnet" "two-tier-subnet-private-1" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Priv1"
  }
}

resource "aws_subnet" "two-tier-subnet-private-2" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Priv2"
  }
}

resource "aws_internet_gateway" "two-tier-ig" {
  vpc_id = aws_vpc.two-tier-vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.two-tier-vpc.id
  tags = {
    Name = "PublicRT"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.two-tier-ig.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.two-tier-subnet-public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.two-tier-subnet-public-2.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for private subnets
resource "aws_eip" "nat" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id      = aws_subnet.two-tier-subnet-public-1.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.two-tier-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.two-tier-subnet-private-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.two-tier-subnet-private-2.id
  route_table_id = aws_route_table.private.id
}
