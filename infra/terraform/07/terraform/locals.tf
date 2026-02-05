# locals.tf - Local values for consistent naming and configuration
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  ssm_parameter_defaults = {
    type        = "SecureString"
    overwrite   = true
    description = "Managed by Terraform"
  }

  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    CostCenter  = "bootcamp"
  }
}
