terraform {
 required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket = "terraform-state-test-ktb-morgan"
    key  = "dev/terraform/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}

resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_main_cidr
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "vpc_morgan_terraform_2"
  }
  
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr_block" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = cidrsubnet(aws_vpc.test_vpc.cidr_block, 8, 0)
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = cidrsubnet(aws_vpc.test_vpc.cidr_block, 8, 1)
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr_block.cidr_block, 8, 0)
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr_block.cidr_block, 8, 1)
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test_internet_gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_nat_1.id
  }

  tags = {
    Name = "private_route_table_1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_nat_2.id
  }

  tags = {
    Name = "private_route_table_2"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id  
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id  
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id  
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id  
}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "test_nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id = aws_subnet.public_subnet_1.id

  depends_on = [ aws_internet_gateway.test_igw ]

  tags = {
    Name = "nat_gateway_azone"
  }
}

resource "aws_nat_gateway" "test_nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id = aws_subnet.public_subnet_2.id

  depends_on = [ aws_internet_gateway.test_igw ]

  tags = {
    Name = "nat_gateway_czone"
  }
}