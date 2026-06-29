variable "kms_key_arn" {
  description = "ARN of the KMS key for Cloudtrail"
  type        = string
}

variable "account_id" {
  description = "ID of the account used to create the s3 bucket so its globally unique"
  type        = string
}