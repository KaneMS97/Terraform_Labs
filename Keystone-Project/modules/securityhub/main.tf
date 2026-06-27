resource "aws_securityhub_account" "securityhub_account" {
}

data "aws_region" "current" {
  
}

resource "aws_securityhub_standards_subscription" "cis" {
  depends_on    = [aws_securityhub_account.securityhub_account]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.region}::standards/cis-aws-foundations-benchmark/v/5.0.0"
}