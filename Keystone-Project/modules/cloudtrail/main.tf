resource "aws_s3_bucket" "cloud_trail_bucket" {
  bucket = "cloudtrail-bucket-${var.account_id}"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_s3_encryption" {
  bucket = aws_s3_bucket.cloud_trail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "cloud_trail_s3_policy" {
  bucket = aws_s3_bucket.cloud_trail_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudtrail_access.json

}

data "aws_region" "current" {
  
}

data "aws_iam_policy_document" "allow_cloudtrail_access" {
  statement { 
    effect = "Allow"
    principals {
        type = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.cloud_trail_bucket.id}"]
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = ["arn:aws:cloudtrail:${data.aws_region.current.region}:${var.account_id}:trail/landing-zone-trail"]

    }
  }

  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject" ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.cloud_trail_bucket.id}/AWSLogs/${var.account_id}/*"]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = ["aws:kms"]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [ "arn:aws:cloudtrail:${data.aws_region.current.region}:${var.account_id}:trail/landing-zone-trail" ]
    }
  }
}

resource "aws_cloudtrail" "landing_zone_trail" {
  depends_on = [ aws_s3_bucket_policy.cloud_trail_s3_policy ]
  name = "landing-zone-trail"
  s3_bucket_name = aws_s3_bucket.cloud_trail_bucket.id
  is_multi_region_trail = true
  include_global_service_events = true
  enable_log_file_validation = true
  kms_key_id = var.kms_key_arn
}