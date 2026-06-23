resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 4
}

data "aws_iam_policy_document" "mfa_policy" {
statement {
  effect = "Allow"
  actions = [  "iam:GetUser", "iam:CreateVirtualMFADevice", "iam:ListMFADevices","iam:ResyncMFADevice","iam:DeleteVirtualMFADevice","iam:EnableMFADevice"]
  resources = []
}

  statement {
    effect = "Deny"
    not_actions = ["iam:GetUser", "iam:CreateVirtualMFADevice", "iam:ListMFADevices","iam:ResyncMFADevice","iam:DeleteVirtualMFADevice","iam:EnableMFADevice"]
    resources = ["*"]
    condition {
      test = "ForAnyValue:StringEquals"
      variable = "aws:MultiFactorAuthPresent"
      values = ["true"]
    }
  }
}
