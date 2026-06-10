resource "aws_vpc" "vpc" {

  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  for_each = toset(var.public_subnet) 

  tags = {
    Name = var.name
}
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  for_each = toset(var.public_subnet) 

  tags = {
    Name = var.name
}
}
