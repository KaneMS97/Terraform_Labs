variable "region" {
  description = "our default region for our instances"
  type        = string
  default     = "eu-west-2"
}

variable "ami_id" {
  description = "The AMI ID we will be using"
  type        = string
  default     = "ami-0eb260c4d5475b901"
}

variable "permitted_size" {
  description = "the instance sizes that are allowed"
  type        = string
  default     = "t2.micro"
}

variable "subnet_cidr" {
  description = "the subnets that are avaiable"
  type        = string
  default     = "10.0.1.0/24"
}
variable "vpc_cidr" {
  description = "Value of our vpc cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name_tags" {
  description = "A List of the Names we will use in tags"
  type        = map(string)
  default = {
    instance = "FirstTerraformServer"
    vpc      = "Project VPC"
    subnet   = "Main Public VPC"
    igw      = "IGW Project"

  }
}