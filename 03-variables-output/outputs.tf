output "vpc_id" {
  description = "The VPC ID that was created"
  value = aws_vpc.New_VPC.id
}

output "ec2_ip" {
  description = "The ID of the ec2 instance that was created"
  value = aws_instance.my_first_server.public_ip
}

output "subnet_ip" {
  description = "The ID of the subnet"
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "The Security Group ID"
  value = aws_security_group.test.id
}