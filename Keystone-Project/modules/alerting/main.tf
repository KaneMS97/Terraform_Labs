resource "aws_sns_topic" "sns_alerts" {
  name = "sns-alerts-topic"

}

resource "aws_sns_topic_subscription" "user_updates_email" {
  topic_arn = aws_sns_topic.sns_alerts.arn
  protocol  = "email"
  endpoint  = var.email
}
