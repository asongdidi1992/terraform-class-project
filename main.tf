terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
tags = {
  "Name" = "tf_vpc"
}
}

# create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "tf_igw"
  }
}
# create Route Table

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tf-rt"
  }
}
# create Public Subnet

resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pub-tf-subnet"
  }
}

resource "aws_route_table_association" "sub_association" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.route_table.id
}
# create Security group with port 22 & 443
resource "aws_security_group" "ssh_https_sg" {
  name        = "allow_https_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_https_ssh"
  }
}

ingress {
    description      = "ssh traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "ssh"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "ssh"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
   

 