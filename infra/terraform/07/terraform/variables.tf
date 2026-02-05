# variables.tf - Input variables for the infrastructure
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aw-bootcamp"
}

variable "ssm_parameters" {
  description = "Map of SSM parameters to create"
  type = map(object({
    description = string
    value       = string
    type        = optional(string, "SecureString")
    key_id      = optional(string, "alias/aws/ssm")
  }))
  default = {}
}

variable "github_repo" {
  description = "GitHub repository for IAM role trust policy"
  type        = string
  default     = ""
}

variable "enable_cicd_access" {
  description = "Enable IAM role for CI/CD access to SSM parameters"
  type        = bool
  default     = true
}
