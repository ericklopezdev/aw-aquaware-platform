# GitHub Actions - Quality & Security CI

Copy this file to your GitHub repository:
```bash
cp .github/workflows/quality-security-ci.yml /path/to/your-repo/.github/workflows/
```

## Copy PHP Project Files

```bash
# Copy to your application repository
cp -r php-project/src /path/to/your-repo/
cp php-project/composer.json /path/to/your-repo/
cp php-project/Dockerfile /path/to/your-repo/
```

## Install Dependencies

```bash
cd /path/to/your-repo
composer install
```

## Test Locally

```bash
# Run PHPStan
vendor/bin/phpstan analyse src --level=7

# Test PHP app
php src/index.php

# Build and test Docker image
docker build -t aw-bootcamp-app .
docker run aw-bootcamp-app
```
