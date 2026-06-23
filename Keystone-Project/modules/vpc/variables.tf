variable "cidr_block" {
  description = "The CIDR to be used for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name of the vpc"
  type        = string
}

variable "public_cidrs" {
  description = "Cidr of my public subnet/s"
  type        = list(string)
}

variable "private_cidrs" {
  description = "Cidr of my private subnet/s"
  type        = list(string)
}