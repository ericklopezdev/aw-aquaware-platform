# Test GitHub Actions - Day 7 Quality & Security

## Disable Existing Workflow

Your repo likely has `ci.yaml`. Disable or rename it:

### Option 1: Rename (keeps history)
```bash
mv .github/workflows/ci.yaml .github/workflows/ci.yaml.disabled
```

### Option 2: Delete (removes entirely)
```bash
rm .github/workflows/ci.yaml
```

### Option 3: Keep but ignore PHP files
Edit `ci.yaml` and add skip condition:
```yaml
jobs:
  build:
    if: "!contains(join(filesModified('.'), ' '), '.php')"
```

---

## Verify Workflow File is Active

```bash
# Check workflow exists
ls -la .github/workflows/

# Expected output:
# quality-security-ci.yml    ← This should be present
```

---

## Trigger the Workflow

### Method 1: Push a Change
```bash
git add .
git commit -m "Trigger Day 7 workflow"
git push origin main
```

### Method 2: Create Pull Request
```bash
# Create a branch
git checkout -b test-day7

# Make a small change
echo "# Test" >> README.md

# Push and create PR
git add .
git commit -m "Test PR for Day 7"
git push -u origin test-day7

# Then create PR at: https://github.com/your-username/aw-devops-platform/pull/new/test-day7
```

---

## Watch the Workflow Run

1. Go to **https://github.com/your-username/aw-devops-platform/actions**
2. Click on **"Quality & Security CI"**
3. Watch jobs execute in real-time:

### Expected Jobs:
| Job | Status | Description |
|-----|--------|-------------|
| `php-static-analysis` | 🟡 Running | PHPStan analyzes PHP code |
| `sonarcloud-analysis` | ⏳ Waiting | SonarCloud static analysis |
| `container-security-scan` | ⏳ Waiting | Trivy container scan |
| `retrieve-ssm-config` | ⏳ Waiting | Fetches secrets from SSM |
| `quality-gate` | ⏳ Waiting | Final pass/fail check |

---

## Expected Results (Success)

```
✅ php-static-analysis         - PHPStan passed
✅ sonarcloud-analysis         - Quality gate passed
✅ container-security-scan     - No critical vulnerabilities
✅ retrieve-ssm-config         - Secrets retrieved
✅ quality-gate                - All checks passed
```

---

## Test Failure Scenarios

### Test 1: PHPStan Failure
```bash
# Add bad PHP code
cat > src/test-bad.php << 'EOF'
<?php
// This will fail PHPStan - undefined variable
echo $undefinedVariable;
EOF

git add src/test-bad.php
git commit -m "Test PHPStan failure"
git push
```

**Expected:** `php-static-analysis` job fails ❌

### Test 2: Trivy Vulnerability
```bash
# Create vulnerable Dockerfile
cat > Dockerfile << 'EOF'
FROM alpine:3.10  # Old version with known CVEs
RUN apk add --no-cache curl
CMD ["curl"]
EOF

git add Dockerfile
git commit -m "Test Trivy vulnerability"
git push
```

**Expected:** `container-security-scan` job fails with CRITICAL/HIGH findings ❌

### Test 3: SSM Parameter Missing
```bash
# Change SSM parameter name in workflow (temporarily)
# Edit .github/workflows/quality-security-ci.yml line 142
# Change: /aw-bootcamp/dev/database/password
# To:     /aw-bootcamp/dev/database/wrong-password

git add .
git commit -m "Test SSM missing parameter"
git push
```

**Expected:** `retrieve-ssm-config` job fails ❌

---

## Cleanup After Testing

```bash
# Re-enable original workflow
mv .github/workflows/ci.yaml.disabled .github/workflows/ci.yaml

# Or delete Day 7 workflow
rm .github/workflows/quality-security-ci.yml

# Commit and push
git add .
git commit -m "Disable Day 7 workflow after testing"
git push
```

---

## Troubleshooting GitHub Actions

| Issue | Solution |
|-------|----------|
| Workflow not showing | Check file is in `.github/workflows/` |
| Job stuck on "Waiting" | Check previous job dependencies |
| PHPStan timeout | Increase `timeout-minutes` in workflow |
| SSM access denied | Verify AWS secrets are set in GitHub |
| SonarCloud fails | Verify `SONAR_TOKEN` secret is valid |
| Trivy fails | Check Docker build succeeded |

### View Logs
1. Go to **Actions** → **Quality & Security CI**
2. Click on failing job
3. Expand step to see error details

### Re-run Workflow
On the workflow page, click **"Re-run all jobs"** (top right).
