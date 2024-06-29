resource "aws_secretsmanager_secret" "this" {
  name = "API"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    url    = ""
    splunk  = ""
    username = ""
    password = ""
    api_key = ""
  })
}

resource "aws_secretsmanager_secret_rotation" "this" {
  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.lambda_arn

  rotation_rules {
    automatically_after_days = 9
  }
}
