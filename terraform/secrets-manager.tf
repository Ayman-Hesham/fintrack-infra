resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/db/credentials"
  description             = "Database credentials"
  recovery_window_in_days = 0
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.main.username
    password = random_password.db_password.result
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    database = aws_db_instance.main.db_name
    url      = "postgresql://${aws_db_instance.main.username}:${random_password.db_password.result}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  })
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}/app/secrets"
  description             = "Application secrets"
  recovery_window_in_days = 0
}

resource "random_string" "jwt_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    jwt_secret           = random_string.jwt_secret.result
    api_key              = "change-me-in-console"
    cors_allowed_origins = "*"
    slack_webhook        = "optional"
  })
}

