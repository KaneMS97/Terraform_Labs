terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my_first_server" {
  ami           = var.ami_id
  instance_type = var.permitted_size

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.test.id]

  tags = {
    Name = var.name_tags["instance"]
  }
}

resource "aws_vpc" "New_VPC" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.name_tags["vpc"]
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.New_VPC.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.name_tags["subnet"]
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.New_VPC.id

  tags = {
    Name = var.name_tags["igw"]
  }
}

resource "aws_route_table" "project_table" {
  vpc_id = aws_vpc.New_VPC.id

  route {
    gateway_id = aws_internet_gateway.IGW.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_security_group" "test" {
  vpc_id = aws_vpc.New_VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table_association" "test" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.project_table.id
}