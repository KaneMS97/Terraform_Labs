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

resource "aws_iam_policy" "require mfa" {

}

data "aws_iam_policy_document" "trust_policy" {

}

resource "aws_iam_role" "trust_policy_role" {
  assume_role_policy = data.aws_iam_policy_document.trust_policy
}

resource "aws_iam_role_policy_attachment" "name" {

}