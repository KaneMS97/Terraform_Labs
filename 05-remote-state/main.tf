#This would be commented out so first create the bucket using the below. Then uncomment out the S3 for the state file.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  /*
  backend "s3" {
    bucket = "kanes-terraform-state-2026"
    key = "terraform.tfstate"
    region = "eu-west-2"
    use_lockfile = true
    
  }*/
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "test" {
  bucket = "kanes-terraform-state-2026"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_test" {
  bucket = aws_s3_bucket.test.id
  versioning_configuration {
    status = "Enabled"
  }
}