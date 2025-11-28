# Archive the Python code automatically (No manual zipping needed!)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/remediate.py"
  output_path = "../lambda/remediate.zip"
}

resource "aws_lambda_function" "remediator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "guardduty-remediator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "remediate.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      QUARANTINE_SG_ID = aws_security_group.quarantine_sg.id
      SNS_TOPIC_ARN    = aws_sns_topic.alerts.arn
    }
  }
}

# Trigger: EventBridge Rule
resource "aws_cloudwatch_event_rule" "gd_rule" {
  name        = "guardduty-finding-rule"
  description = "Trigger Lambda on High Severity GuardDuty Findings"

  event_pattern = jsonencode({
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"],
    # We want to catch everything for testing, usually you filter by severity
    "detail": {
       "severity": [ { "numeric": [ ">", 0 ] } ] 
    }
  })
}

resource "aws_cloudwatch_event_target" "target_lambda" {
  rule      = aws_cloudwatch_event_rule.gd_rule.name
  arn       = aws_lambda_function.remediator.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gd_rule.arn
}