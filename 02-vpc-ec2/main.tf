terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "my_first_server" {
  ami           = "ami-0eb260c4d5475b901"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.test.id]

  tags = {
    Name = "FirstTerraformServer"
  }
}

resource "aws_vpc" "New_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.New_VPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main Public VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.New_VPC.id

  tags = {
    Name = "IGW Project"
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