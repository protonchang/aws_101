# Configure the AWS Provider
terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0"
      }
    }
    backend "local" {
      path = "./terraform.tfstate"
    }
}

provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "workshop-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "workshop-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "workshop-igw" {
  vpc_id = aws_vpc.workshop-vpc.id

  tags = {
    Name = "workshop-igw"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.workshop-vpc.id
  cidr_block              = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.workshop-vpc.id
  cidr_block        = "10.0.${count.index * 2 + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.workshop-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.workshop-igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.workshop-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}