# Test Locally - Day 7 Quality & Security

## Install PHP

### macOS
```bash
brew install php@8.2
echo 'export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
php -v
```

### Linux (Ubuntu/Debian)
```bash
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php8.2 php8.2-cli php8.2-xml php8.2-mbstring php8.2-curl php8.2-json
php -v
```

### Windows
```bash
# Download from https://windows.php.net/download/
# Or use Chocolatey
choco install php-8.2
```

---

## Install Dependencies

```bash
cd /path/to/aw-devops-platform

# Install Composer (if not installed)
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install PHP dependencies
composer install --no-interaction
```

---

## Test PHPStan Locally

```bash
# Run PHPStan analysis
vendor/bin/phpstan analyse src --level=7

# Or with composer script
composer analyse
```

**Expected output:** No errors for the sample PHP code.

---

## Test Docker Build Locally

### Install Docker
```bash
# macOS
brew install --cask docker

# Ubuntu
sudo apt install docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

# Windows
# Download from https://www.docker.com/products/docker-desktop
```

### Build and Test Image

```bash
# Build the Docker image
docker build -t aw-bootcamp-app .

# Run the container
docker run --rm aw-bootcamp-app

# Expected output:
# Calculator Tests:
# =================
# 2 + 3 = 5
# 10 - 4 = 6
# 5 * 6 = 30
# 20 / 4 = 5
#
# User Tests:
# ===========
# Hello, my name is John Doe
# Email: john@example.com
# Age: 30
```

---

## Test Trivy Locally (Optional)

### Install Trivy
```bash
# macOS
brew install trivy

# Linux
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Windows
choco install trivy
```

### Scan Docker Image

```bash
# Scan the local image
trivy image aw-bootcamp-app

# Scan with high/critical severity filter
trivy image --severity HIGH,CRITICAL aw-bootcamp-app
```

---

## Full Local Test Script

```bash
#!/bin/bash
set -e

echo "=== Day 7 Local Testing ==="
echo ""

echo "1. Installing dependencies..."
composer install --no-interaction

echo ""
echo "2. Running PHPStan..."
vendor/bin/phpstan analyse src --level=7

echo ""
echo "3. Building Docker image..."
docker build -t aw-bootcamp-app .

echo ""
echo "4. Testing Docker image..."
docker run --rm aw-bootcamp-app

echo ""
echo "5. Scanning with Trivy..."
trivy image --severity HIGH,CRITICAL aw-bootcamp-app || true

echo ""
echo "=== All local tests passed ==="
```

Save as `test-local.sh` and run:
```bash
chmod +x test-local.sh
./test-local.sh
```
