# iam.tf - IAM policies for least-privilege CI/CD access to SSM Parameters

# IAM role for GitHub Actions OIDC (OpenID Connect)
resource "aws_iam_role" "github_actions" {
  count = var.enable_cicd_access && var.github_repo != "" ? 1 : 0

  name = "${local.name_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Policy document for SSM parameter read-only access (least privilege)
data "aws_iam_policy_document" "ssm_read_only" {
  statement {
    sid = "AllowReadSSMParameters"

    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.environment}/*"
    ]
  }

  statement {
    sid = "AllowKMSDecrypt"

    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/alias/aws/ssm"
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${var.aws_region}.amazonaws.com"]
    }
  }
}

# Policy document for SSM parameter write access (for CI/CD deployments)
data "aws_iam_policy_document" "ssm_read_write" {
  count = var.enable_cicd_access ? 1 : 0

  source_policy_documents = [data.aws_iam_policy_document.ssm_read_only.json]

  statement {
    sid = "AllowWriteSSMParameters"

    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.environment}/*"
    ]
  }
}

# IAM policy for read-only access (used by app runtime)
resource "aws_iam_policy" "ssm_read_only" {
  count = var.enable_cicd_access ? 1 : 0

  name        = "${local.name_prefix}-ssm-read-only-policy"
  description = "Read-only access to SSM parameters for application runtime"
  policy      = data.aws_iam_policy_document.ssm_read_only.json

  tags = local.common_tags
}

# IAM policy for read-write access (used by CI/CD pipeline)
resource "aws_iam_policy" "ssm_read_write" {
  count = var.enable_cicd_access ? 1 : 0

  name        = "${local.name_prefix}-ssm-read-write-policy"
  description = "Read-write access to SSM parameters for CI/CD pipeline"
  policy      = data.aws_iam_policy_document.ssm_read_write[0].json

  tags = local.common_tags
}

# Attach read-only policy to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_ssm_read" {
  count = var.enable_cicd_access && var.github_repo != "" ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.ssm_read_only[0].arn
}

# Attach read-write policy to the GitHub Actions role (optional - for deployments)
resource "aws_iam_role_policy_attachment" "github_ssm_write" {
  count = var.enable_cicd_access && var.github_repo != "" ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.ssm_read_write[0].arn
}
