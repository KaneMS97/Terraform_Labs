resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 14
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
    effect  = "Allow"
    actions = ["iam:GetUser", "iam:CreateVirtualMFADevice", "iam:ListMFADevices", "iam:ResyncMFADevice", "iam:DeleteVirtualMFADevice", "iam:EnableMFADevice"]
    resources = ["arn:aws:iam::${var.account_id}:user/$${aws:username}",
    "arn:aws:iam::${var.account_id}:mfa/$${aws:username}"]
  }

  statement {
    effect      = "Deny"
    not_actions = ["iam:GetUser", "iam:CreateVirtualMFADevice", "iam:ListMFADevices", "iam:ResyncMFADevice", "iam:DeleteVirtualMFADevice", "iam:EnableMFADevice"]
    resources   = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_group" "all_users" {
  name = "all-users"
}

resource "aws_iam_policy" "mfa_group_policy" {
  name   = "my-mfa-policy"
  policy = data.aws_iam_policy_document.mfa_policy.json
}

resource "aws_iam_group_policy_attachment" "name" {
  group      = aws_iam_group.all_users.name
  policy_arn = aws_iam_policy.mfa_group_policy.arn
}