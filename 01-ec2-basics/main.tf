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

  tags = {
    Name = "FirstTerraformServer"
  }
}