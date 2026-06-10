variable "vpc_id" {
  description = "The ID of VPC"
  type        = string

}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "my-subnet"
}

variable "availability_zone" {
  description = "AZ for the subnet"
  type        = string
  default     = "eu-west-2a"
}