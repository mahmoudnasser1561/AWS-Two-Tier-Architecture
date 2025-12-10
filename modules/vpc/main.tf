resource "aws_vpc" "two-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TTVPC"
  }
}

resource "aws_subnet" "bastion_pub" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "BastionPub"
  }
}

resource "aws_subnet" "nat_pub" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "NatPub"
  }
}

resource "aws_subnet" "web_priv1" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "WebPriv1"
  }
}

resource "aws_subnet" "web_priv2" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "WebPriv2"
  }
}

resource "aws_subnet" "db_priv1" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DbPriv1"
  }
}

resource "aws_subnet" "db_priv2" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DbPriv2"
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

resource "aws_route_table_association" "bastion_pub" {
  subnet_id      = aws_subnet.bastion_pub.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "nat_pub" {
  subnet_id      = aws_subnet.nat_pub.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.nat_pub.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.two-tier-vpc.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "web_priv1" {
  subnet_id      = aws_subnet.web_priv1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "web_priv2" {
  subnet_id      = aws_subnet.web_priv2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_priv1" {
  subnet_id      = aws_subnet.db_priv1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_priv2" {
  subnet_id      = aws_subnet.db_priv2.id
  route_table_id = aws_route_table.private.id
}