variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "enviroment" {
  description = "Enviroment name for Tagging"
  type        = string
  default     = "learning-terraform"
}