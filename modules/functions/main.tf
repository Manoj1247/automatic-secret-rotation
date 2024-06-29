resource "aws_lambda_function" "this" {
  filename      = "${path.module}/lambda_function_payload.zip"
  function_name = "automatic-secrets-rotation"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      secret_id = var.secret_id
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Define inline policy for Lambda function to access Secrets Manager
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ]
      Resource  = var.secret_arn
    },
    {
        Effect = "Allow"
        Action = [
            "secretsmanager:GetRandomPassword"
        ]
        Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionFromASM"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = var.secret_arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.event_rule_arn
}

