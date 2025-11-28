resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "aws_sns_topic" "alerts" {
  name = "security-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "jaswanths.mutyala@gmail.com"
}