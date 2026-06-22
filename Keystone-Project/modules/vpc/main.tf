resource "aws_vpc" "vpc" {

  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  for_each = toset(var.public_cidrs)
  cidr_block = each.value

  tags = {
    Name = var.name
}
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_cidrs)
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value

  tags = {
    Name = var.name
}
}

resource "aws_flow_log" "main_log" {
  iam_role_arn = aws_iam_role.flow_log_role.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.vpc.id
  log_destination = aws_cloudwatch_log_group.log_location.arn
  
}

resource "aws_cloudwatch_log_group" "log_location" {
  name = "loglocation"
  retention_in_days = 365
}

resource "aws_iam_role" "flow_log_role" {
  assume_role_policy = data.aws_iam_policy_document.flow_log_policy.json
}

data "aws_iam_policy_document" "flow_log_policy" {
  statement {
    effect = "Allow"
  principals {
    type = "Service" 
    identifiers = [ "vpc-flow-logs.amazonaws.com" ]
  }
  actions = [ "sts:AssumeRole" ]
  }
}

data "aws_iam_policy_document" "flow_log_permission" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
    ]
    resources = [ "${aws_cloudwatch_log_group.log_location.arn}:*" ]
  }
}

resource "aws_iam_role_policy" "flow_log_iam_policy" {
  name = "test"
  role = aws_iam_role.flow_log_role.id
  policy = data.aws_iam_policy_document.flow_log_permission.json
}