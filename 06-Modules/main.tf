module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "demo-vpc"
}

module "subnet_module" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  subnet_cidr       = "10.0.1.0/24"
  subnet_name       = "demo-subnet"
  availability_zone = "eu-west-2a"
}

module "ec2_module" {
  source        = "./modules/ec2"
  instance_type = "t2.micro"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.subnet_module.subnet_id
  ami_id        = "ami-0eb260c4d5475b901"
  instance_name = "test-instance"

}