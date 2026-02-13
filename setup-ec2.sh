#!/bin/bash

# EC2 Setup Script for Calculator Application Deployment
# Run this script on a fresh Amazon Linux 2 or Amazon Linux 2023 instance
# Usage: bash setup-ec2.sh

set -e

echo "================================================"
echo "EC2 Setup for Calculator Application"
echo "================================================"

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo"
   exit 1
fi

echo "Installing system updates..."
yum update -y

echo "Installing Java 21..."
yum install java-21-amazon-corretto-headless -y

echo "Installing utilities (curl, wget, htop, git)..."
yum install curl wget htop git -y

echo "Verifying Java installation..."
java -version

echo ""
echo "================================================"
echo "✓ EC2 Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Create application directory:"
echo "   mkdir -p ~/calculator-app && chmod 755 ~/calculator-app"
echo ""
echo "2. Ensure your SSH key is in ~/.ssh/authorized_keys"
echo ""
echo "3. Add these GitHub repository secrets:"
echo "   - EC2_SSH_PRIVATE_KEY: Your private SSH key"
echo "   - EC2_HOST: This instance's public IP or hostname"
echo ""
echo "4. Push code to main branch to trigger CI/CD deployment"
echo ""
echo "To verify setup:"
echo "  java -version"
echo "  ls -la ~/calculator-app"
echo ""
echo "To view deployment logs after deployment:"
echo "  tail -f ~/calculator-app/app.log"
echo ""
