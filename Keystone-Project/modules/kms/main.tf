resource "aws_kms_key" "cloud_trail_key" {
  description             = "A symmetric encryption KMS key for cloud trail"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

resource "aws_kms_key" "s3_key" {
  description             = "A symmetric encryption KMS key for s3"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

resource "aws_kms_alias" "cloud_trail_alias" {
  name = "alias/cloud-trail-key-alias"
  target_key_id = aws_kms_key.cloud_trail_key.key_id
}

resource "aws_kms_alias" "s3-key-alias" {
  name = "alias/s3-key-alias"
  target_key_id = aws_kms_key.s3_key.key_id
}