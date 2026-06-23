output "cloud_trail_kms_key_arn" {
  value       = aws_kms_key.cloud_trail_key.arn
  description = "The ARN of the cloud trail key"
}

output "s3_kms_key_arn" {
  value       = aws_kms_key.s3_key.arn
  description = "The ARN of the s3 key"
}