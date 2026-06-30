resource "aws_sns_topic" "sns_alerts" {
  name = "sns-alerts-topic"

}

resource "aws_sns_topic_subscription" "user_updates_email" {
  topic_arn = aws_sns_topic.sns_alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "root-login-alarm"
  pattern        = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name          = "RootLoginAlarm"
    namespace     = "LogMetrics"
    value         = 1
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login-alarm" {
  alarm_name          = "login-with-root-account"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootLoginAlarm"
  namespace           = "LogMetrics"
  threshold           = 1
  period              = 120
  statistic           = "Sum"
  alarm_actions       = [aws_sns_topic.sns_alerts.arn]
  alarm_description   = "This sends an email whenever the root account is used"
}

resource "aws_cloudwatch_log_metric_filter" "login_no_mfa" {
  name           = "console-login-no-mfa"
  pattern        = "{($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\")}"
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name          = "ConsoleLoginWithoutMFA"
    namespace     = "LogMetrics"
    value         = 1
    default_value = 0

  }
}
resource "aws_cloudwatch_metric_alarm" "login_no_mfa" {
  alarm_name          = "login-with-no-mfa"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginWithoutMFA"
  namespace           = "LogMetrics"
  threshold           = 1
  period              = 120
  statistic           = "Sum"
  alarm_actions       = [aws_sns_topic.sns_alerts.arn]
  alarm_description   = "This Metric monitors the amount of accounts who login without mfa"
}

resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  name           = "changes-to-security-group"
  pattern        = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name          = "ChangesToSecurityGroup"
    namespace     = "LogMetrics"
    value         = 1
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "changes_to_security_group" {
  alarm_name          = "changes-to-security-group"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ChangesToSecurityGroup"
  namespace           = "LogMetrics"
  threshold           = 1
  period              = 120
  statistic           = "Sum"
  alarm_actions       = [aws_sns_topic.sns_alerts.arn]
  alarm_description   = "This send an alarm when a change is made to the security group"
}

resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  name           = "changes-to-iam-policy"
  pattern        = "{($.eventSource=iam.amazonaws.com) && (($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy))}"
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name          = "ChangesToIamPolicy"
    namespace     = "LogMetrics"
    value         = 1
    default_value = 0
  }
}


resource "aws_cloudwatch_metric_alarm" "changes_to_iam_policy" {
  alarm_name          = "changes-to-iam-policy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ChangesToIamPolicy"
  namespace           = "LogMetrics"
  threshold           = 1
  period              = 120
  statistic           = "Sum"
  alarm_actions       = [aws_sns_topic.sns_alerts.arn]
  alarm_description   = "This Metric monitors the amount of accounts who login without mfa"
}