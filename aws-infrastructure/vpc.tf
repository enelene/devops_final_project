# Create a VPC
resource "aws_vpc" "final_project" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "final-project"
  }
}

# Create public and private subnets in AZ eu-central-1a
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.final_project.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.final_project.id
  cidr_block        = "10.0.5.0/24"  # Updated CIDR block to avoid conflict
  availability_zone = "eu-central-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

# Create public and private subnets in AZ eu-central-1b
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.final_project.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.final_project.id
  cidr_block        = "10.0.6.0/24"  # Updated CIDR block to avoid conflict
  availability_zone = "eu-central-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "final_project_igw" {
  vpc_id = aws_vpc.final_project.id

  tags = {
    Name = "final-project-igw"
  }
}

# Create a public route table and add a route to the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.final_project.id

  tags = {
    Name = "public-rt-final-project"
  }
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.final_project_igw.id
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a NAT Gateway in one of the public subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "final_project_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "final-project-nat"
  }

  depends_on = [aws_internet_gateway.final_project_igw]
}

# Create private route tables and add a route to the NAT Gateway
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.final_project.id

  tags = {
    Name = "private-rt-1-final-project"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.final_project.id

  tags = {
    Name = "private-rt-2-final-project"
  }
}

resource "aws_route" "private_rt_1_nat_route" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.final_project_nat.id

  depends_on = [aws_nat_gateway.final_project_nat]
}

resource "aws_route" "private_rt_2_nat_route" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.final_project_nat.id

  depends_on = [aws_nat_gateway.final_project_nat]
}

# Associate the private route tables with the private subnets
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}