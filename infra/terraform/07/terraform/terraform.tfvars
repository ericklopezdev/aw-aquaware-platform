# terraform.tfvars.example - Example variable configuration
# Copy this to terraform.tfvars and modify as needed

aws_region  = "us-east-1"
environment = "dev"
project_name = "aw-bootcamp"

# GitHub repository for IAM role (format: owner/repository)
github_repo = "your-org/your-repo"

# Enable CI/CD IAM role
enable_cicd_access = true

# SSM parameters to create
# Parameters will be created with AWS-managed KMS encryption
ssm_parameters = {
  "/aw-bootcamp/dev/database/host" = {
    description = "Database host URL"
    value       = "db.example.com"
  }
  "/aw-bootcamp/dev/database/name" = {
    description = "Database name"
    value       = "app_db"
  }
  "/aw-bootcamp/dev/cache/endpoint" = {
    description = "Cache endpoint"
    value       = "cache.example.com:6379"
  }
}
