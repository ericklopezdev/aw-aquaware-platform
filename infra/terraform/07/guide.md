# Day 7 - Quality & Security Lab Guide

## Prerequisites

### 1. AWS CLI
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Configure
aws configure
# Set: us-east-1, json format, your Access Key ID and Secret Access Key
```

### 2. Terraform >= 1.5.0
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### 3. GitHub Account
- Repository at GitHub.com
- SonarCloud account (free) at [sonarcloud.io](https://sonarcloud.io)

---

## Lab Steps

Since this is a monorepo and you don't have PHP locally, **all testing happens through GitHub Actions** (PHP is installed automatically in the CI pipeline).

### Step 1: Copy PHP Project Files to Your Application Repo

This is the bootstrap repo for all days. To test Day 7, copy the PHP project to a separate application repository:

```bash
# From the bootstrap repo (this directory)
cd /path/to/aw-devops-platform/infra/terraform/07

# Clone/create your app repo (if not exists)
git clone https://github.com/your-username/your-php-app.git
cd your-php-app

# Copy PHP project files
cp -r ../php-project/* .

# Commit and push
git add .
git commit -m "Add Day 7 PHP test project"
git push origin main
```

### Step 2: Copy GitHub Actions Workflow

```bash
# From this directory (infra/terraform/07)
cp .github/workflows/quality-security-ci.yml /path/to/your-php-app/.github/workflows/

cd /path/to/your-php-app
git add .
git commit -m "Add Day 7 quality and security workflow"
git push origin main
```

### Step 3: Deploy Infrastructure

```bash
cd infra/terraform/07/terraform

# Copy example vars
cp terraform.tfvars.example terraform.tfvars
# Edit with your values:
# - github_repo = "your-username/your-php-app"
# - project_name = "aw-bootcamp"
# - environment = "dev"

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

### Step 4: Create SSM Parameters (in AWS)

```bash
aws ssm put-parameter \
  --name "/aw-bootcamp/dev/database/password" \
  --value "YourSecurePassword123!" \
  --type SecureString \
  --region us-east-1

aws ssm put-parameter \
  --name "/aw-bootcamp/dev/api/key" \
  --value "YourApiKeySecret" \
  --type SecureString \
  --region us-east-1
```

### Step 5: Configure GitHub Secrets

Go to **your-php-app** repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:
| Secret Name | Value |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | From AWS IAM user |
| `AWS_SECRET_ACCESS_KEY` | From AWS IAM user |
| `SONAR_TOKEN` | Get from [sonarcloud.io](https://sonarcloud.io) → My Account → Security |

### Step 6: Trigger the Workflow

Push anything to `main` or `develop` branch, or create a PR to `main`:

```bash
cd /path/to/your-php-app
echo "# Test update" >> README.md
git add .
git commit -m "Trigger Day 7 workflow"
git push
```

### Step 7: Watch GitHub Actions

1. Go to **your-php-app** → **Actions** tab
2. Watch "Quality & Security CI" run
3. PHP will be installed automatically by `shivammathur/setup-php@v2`

---

## Verifying It Works

### Check GitHub Actions
1. Go to your repository → **Actions** tab
2. You should see "Quality & Security CI" running
3. Watch the jobs complete:
   - ✅ `php-static-analysis`
   - ✅ `sonarcloud-analysis`
   - ✅ `container-security-scan`
   - ✅ `retrieve-ssm-config`
   - ✅ `quality-gate`

### Test Failure Scenarios

**Test 1: PHPStan failure**
```bash
# Add bad PHP code
cat > src/bad.php << 'EOF'
<?php

// This will fail PHPStan - undefined variable
echo $undefinedVariable;
EOF

git add src/bad.php
git commit -m "Test PHPStan failure"
git push
```

**Test 2: Trivy vulnerability**
```bash
# Add a Dockerfile with vulnerable base image
cat > Dockerfile << 'EOF'
FROM alpine:3.10  # Old version with CVEs
RUN apk add --no-cache curl
CMD ["curl"]
EOF

git add Dockerfile
git commit -m "Test Trivy vulnerability detection"
git push
```

**Expected:** GitHub Actions job should fail with error message.

---

## Cleanup

### Remove SSM Parameters
```bash
aws ssm delete-parameter --name "/aw-bootcamp/dev/database/password"
aws ssm delete-parameter --name "/aw-bootcamp/dev/api/key"
```

### Destroy Terraform Infrastructure
```bash
cd terraform
terraform destroy
```

### Delete SonarCloud Project
1. Go to [sonarcloud.io](https://sonarcloud.io)
2. Find your project → **Administration** → **Delete**

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `aws: command not found` | Install AWS CLI (see Prerequisites) |
| `SONAR_TOKEN` invalid | Regenerate at sonarcloud.io → My Account |
| SSM access denied | Check IAM policy in AWS Console |
| Workflow not running | Check branch names match `on:` triggers |
| PHPStan timeout | Increase step timeout in workflow |

**Note:** PHP is installed automatically in GitHub Actions via `shivammathur/setup-php@v2`. You do NOT need PHP installed locally.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                        │
│                  (PHP code + Dockerfile)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │ Push / PR
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Actions CI                          │
├─────────────────────────────────────────────────────────────┤
│  1. PHPStan         │ Static code analysis (PHP)            │
│  2. SonarCloud      │ SAST with quality gates               │
│  3. Trivy           │ Container image vulnerability scan   │
│  4. AWS SSM         │ Retrieve secrets (passwords, keys)    │
│  5. Quality Gate    │ Pass/Fail all checks                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    AWS SSM Parameter Store                  │
│         (/aw-bootcamp/dev/database/password, etc.)          │
└─────────────────────────────────────────────────────────────┘
```
