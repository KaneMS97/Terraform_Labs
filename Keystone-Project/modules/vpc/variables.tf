variable "cidr_block" {
  description = "The CIDR to be used for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name of the vpc"
  type        = string
  default     = ""
}

variable "public_subnet" {
  description = "Cidr of my public subnet/s"
  type = list(string)
  default = [ "","" ]
}