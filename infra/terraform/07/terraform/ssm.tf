# ssm.tf - SSM Parameter Store configuration for secrets and configuration
# Using AWS-managed KMS key for encryption (cheapest option)

resource "aws_ssm_parameter" "database" {
  for_each = var.ssm_parameters

  name        = each.key
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  key_id      = each.value.key_id
  overwrite   = true

  lifecycle {
    ignore_changes = [value] # Prevent recreation when value changes in Terraform
  }

  tags = local.common_tags
}

# Example: Additional secure parameters (can be used with var.ssm_parameters)
resource "aws_ssm_parameter" "api_key" {
  name        = "/${var.project_name}/${var.environment}/api/key"
  description = "API key for external service"
  type        = "SecureString"
  value       = "change-me-in-production"
  key_id      = "alias/aws/ssm"

  tags = merge(local.common_tags, {
    Sensitivity = "high"
  })
}

resource "aws_ssm_parameter" "db_credentials" {
  name        = "/${var.project_name}/${var.environment}/database/credentials"
  description = "Database connection credentials"
  type        = "SecureString"
  value = jsonencode({
    host     = "db.example.com"
    port     = 5432
    username = "app_user"
    password = "placeholder_password"
  })
  key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(local.common_tags, {
    Sensitivity = "high"
  })
}

resource "aws_ssm_parameter" "app_config" {
  name        = "/${var.project_name}/${var.environment}/app/config"
  description = "Application configuration settings"
  type        = "String"
  value = jsonencode({
    log_level       = "debug"
    feature_flags   = ["new_ui", "beta_features"]
    max_connections = 100
    timeout_seconds = 30
  })

  tags = merge(local.common_tags, {
    Sensitivity = "low"
  })
}
