# create vpc
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "vpc"
  }
}

# create internet gateway and attach it to vpc
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id 

  tags      = {
    Name    = "internet-gateway"
  }
}

# create public production subnet az1
# terraform aws create subnet
resource "aws_subnet" "public_prod_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_prod_subnet_cidr_az1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public-prod-subnet-az1"
  }
}

# create public production subnet az2
# terraform aws create subnet
resource "aws_subnet" "public_prod_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_prod_subnet_cidr_az2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public-prod-subnet-az2"
  }
}

# create public development subnet az1
# terraform aws create subnet
resource "aws_subnet" "public_dev_subnet" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.public_dev_subnet_cidr
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = true

  tags      = {
    Name    = "public-dev-subnet-az1"
  }
}

# create route table and add public route
# terraform aws create route table
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "public-route-table"
  }
}

# associate public production subnet az1 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.public_prod_subnet_az1.id
  route_table_id      = aws_route_table.public_route_table.id
}

# associate public production subnet az2 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id           = aws_subnet.public_prod_subnet_az2.id
  route_table_id      = aws_route_table.public_route_table.id
}

# associate public development subnet az1 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_dev_subnet_route_table_association" {
  subnet_id           = aws_subnet.public_dev_subnet.id
  route_table_id      = aws_route_table.public_route_table.id
}

# create private production data subnet az1
# terraform aws create subnet
resource "aws_subnet" "private_prod_data_subnet_az1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_prod_data_subnet_cidr_1
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private-prod-data-subnet-az1"
  }
}

# create private production data subnet az2
# terraform aws create subnet
resource "aws_subnet" "private_prod_data_subnet_az2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_prod_data_subnet_cidr_2
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private-prod-data-subnet-az2"
  }
}

# create private development data subnet az1
# terraform aws create subnet
resource "aws_subnet" "private_dev_data_subnet_az1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_dev_data_subnet_cidr_1
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private-dev-data-subnet-az1"
  }
}

# create private development data subnet az2
# terraform aws create subnet
resource "aws_subnet" "private_dev_data_subnet_az2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_dev_data_subnet_cidr_2
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private-dev-data-subnet-az2"
  }
}
