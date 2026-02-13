#!/bin/bash

# Quick setup guide for GitHub Secrets
# This script helps you configure the necessary GitHub secrets for CI/CD deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}GitHub Secrets Configuration Guide${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Step 1: Generate or retrieve your SSH private key${NC}"
echo "If you don't have an SSH key pair, generate one:"
echo -e "${GREEN}  ssh-keygen -t rsa -b 4096 -f ~/.ssh/github-ec2${NC}"
echo ""

echo -e "${YELLOW}Step 2: Copy your private SSH key${NC}"
echo "Run this command to copy your private key to clipboard:"
echo -e "${GREEN}  cat ~/.ssh/github-ec2 | pbcopy${NC}"
echo ""

echo -e "${YELLOW}Step 3: Add GitHub secret EC2_SSH_PRIVATE_KEY${NC}"
echo "1. Go to your GitHub repository"
echo "2. Navigate to: Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Name: EC2_SSH_PRIVATE_KEY"
echo "5. Value: Paste your private key (Ctrl+V or Cmd+V)"
echo "6. Click 'Add secret'"
echo ""

echo -e "${YELLOW}Step 4: Get your EC2 instance public IP${NC}"
echo "1. Go to AWS Console → EC2 → Instances"
echo "2. Select your instance"
echo "3. Copy the 'Public IPv4 address' or 'Public IPv4 DNS'"
echo ""

echo -e "${YELLOW}Step 5: Add GitHub secret EC2_HOST${NC}"
echo "1. Go to GitHub repository Settings → Secrets"
echo "2. Click 'New repository secret'"
echo "3. Name: EC2_HOST"
echo "4. Value: Your EC2 public IP or hostname"
echo "5. Click 'Add secret'"
echo ""

echo -e "${YELLOW}Step 6: Setup EC2 instance${NC}"
echo "1. SSH into your EC2 instance:"
echo -e "${GREEN}  ssh -i /path/to/your/key.pem ec2-user@YOUR_EC2_HOST${NC}"
echo ""
echo "2. Run the setup script:"
echo -e "${GREEN}  bash setup-ec2.sh${NC}"
echo ""
echo "3. Add your public SSH key to EC2 authorized_keys:"
echo -e "${GREEN}  echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys${NC}"
echo ""

echo -e "${YELLOW}Step 7: Verify everything is working${NC}"
echo "1. Push code to main branch"
echo "2. Go to GitHub Actions tab"
echo "3. Monitor the workflow execution"
echo "4. Once deployment completes, access the application:"
echo -e "${GREEN}  http://YOUR_EC2_HOST:8080${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Configuration Guide Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Helpful commands:${NC}"
echo ""
echo "View GitHub secrets (list only, not values):"
echo -e "${GREEN}  gh secret list${NC}"
echo ""
echo "Test SSH connection to EC2:"
echo -e "${GREEN}  ssh -i /path/to/your/key.pem ec2-user@YOUR_EC2_HOST${NC}"
echo ""
echo "View application logs on EC2 after deployment:"
echo -e "${GREEN}  ssh -i /path/to/your/key.pem ec2-user@YOUR_EC2_HOST 'tail -f ~/calculator-app/app.log'${NC}"
echo ""
echo "Check if application is running:"
echo -e "${GREEN}  ssh -i /path/to/your/key.pem ec2-user@YOUR_EC2_HOST 'ps aux | grep CalculatorProject'${NC}"
echo ""
