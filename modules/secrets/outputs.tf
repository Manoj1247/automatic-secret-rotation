output secret_id {
  value       = aws_secretsmanager_secret.this.name
}

output secret_arn{
    value = aws_secretsmanager_secret.this.arn
}