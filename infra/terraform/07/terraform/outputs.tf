# outputs.tf - Output values for the infrastructure
output "ssm_parameter_arns" {
  description = "ARNs of created SSM parameters"
  value       = { for param in aws_ssm_parameter.database : param.name => param.arn }
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "ARN of IAM role for GitHub Actions (use in GitHub repository secrets)"
  value       = try(aws_iam_role.github_actions[0].arn, "Not configured - set var.github_repo")
}

output "ssm_parameter_paths" {
  description = "Paths of created SSM parameters for reference"
  value = concat(
    [for param in aws_ssm_parameter.database : param.name],
    [
      aws_ssm_parameter.api_key.name,
      aws_ssm_parameter.db_credentials.name,
      aws_ssm_parameter.app_config.name
    ]
  )
}

output "iam_policy_arns" {
  description = "ARNs of created IAM policies"
  value = {
    read_only  = try(aws_iam_policy.ssm_read_only[0].arn, "Not created"),
    read_write = try(aws_iam_policy.ssm_read_write[0].arn, "Not created")
  }
}
