# CloudWatch Events Rule to trigger daily
resource "aws_cloudwatch_event_rule" "this" {
  name        = "rotation-check"
  description = "Triggers Lambda every 10 days to check for secret rotation"
  schedule_expression = "rate(10 days)"
}

# Lambda function target for the CloudWatch Events Rule
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "lambda-target"
  arn       = var.lambda_arn
}


