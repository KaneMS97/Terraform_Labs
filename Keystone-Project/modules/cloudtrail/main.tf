resource "aws_s3_bucket" "cloud_trail_bucket" {
  bucket = "cloudtrail-bucket"
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_s3_block" {
  bucket = aws_s3_bucket.cloud_trail_bucket.id
  block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_s3_versioning" {
  bucket = aws_s3_bucket.cloud_trail_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_kms_key" "cloudtrail_key" {
  description = "This key is used to encrypt my s3 bucket"
  deletion_window_in_days = 10
}
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_s3_encryption" {
  bucket = aws_s3_bucket.cloud_trail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm = "aws:kms"
    }
  }
}