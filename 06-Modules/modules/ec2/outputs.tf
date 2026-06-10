output "instance_id" {
  description = "The ID of the Instance"
  value       = aws_instance.instance.id
}

output "public_id" {
  description = "The public IP of the instance"
  value       = aws_instance.instance.public_ip
}