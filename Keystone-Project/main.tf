module "vpc" {
  source = "./modules/vpc"

  name       = "my-vpc"
  cidr_block = "10.0.0.0/16"
  public_subnet = [ "10.0.1.0/24","10.0.2.0/24" ]

}

module "subnet" {
  source = "./modules/vpc"

  name = "public-subnet"
  cidr_block = "10.0.1.0/24"  
}

module "subnet" {
  source = "./modules/vpc"
  name = "private-subnet"
  cidr_block = "10.0.2.0/24"

}