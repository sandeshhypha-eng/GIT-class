# Calculator Application CI/CD Deployment Guide

## Overview
This document provides setup instructions for the GitHub Actions CI/CD pipeline that builds and deploys the Calculator Spring Boot application as a JAR file directly to Amazon Linux EC2 instances via SSH.

## Architecture
The CI/CD pipeline consists of two main jobs:
- **build**: Compiles the Maven project, runs tests, and uploads the JAR artifact
- **deploy-to-amazon-linux**: Copies the JAR to EC2 via SCP and starts the application via SSH

## Prerequisites

### 1. GitHub Repository Configuration
- Ensure your repository is accessible and GitHub Actions is enabled

### 2. Amazon Linux EC2 Instance
- An EC2 instance running Amazon Linux 2 or Amazon Linux 2023
- SSH access configured
- Java 21 (or compatible JRE) installed on the EC2 instance:
  ```bash
  sudo yum update -y
  sudo yum install java-21-amazon-corretto-headless -y
  ```
- `curl` installed for health checks:
  ```bash
  sudo yum install curl -y
  ```

## GitHub Secrets Configuration

You must configure the following secrets in your GitHub repository:

1. **EC2_SSH_PRIVATE_KEY**
   - Your private SSH key for EC2 access
   - Set it as a repository secret
   - Format: Paste the entire key content (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

2. **EC2_HOST**
   - The public IP address or hostname of your Amazon Linux EC2 instance
   - Example: `54.123.45.67` or `ec2-instance.amazonaws.com`

### How to Add Secrets:
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the exact name shown above

## Workflow Triggers

The pipeline is triggered automatically on:
- Push to `main` or `develop` branches (when CalculatorProject files change)
- Pull requests to `main` branch
- Manual trigger via GitHub Actions UI (workflow_dispatch)

## Deployment Flow

### Build Stage
1. Checks out the repository
2. Sets up JDK 21 environment
3. Builds the Maven project
4. Runs unit tests
5. Uploads the JAR artifact

### Deploy Stage (Main branch only)
1. Downloads the built JAR from GitHub Actions artifacts
2. Connects to EC2 instance via SSH
3. Creates application directory on EC2
4. Copies JAR file via SCP
5. Stops any existing application (if running)
6. Starts the new application in the background with 512MB memory limit
7. Verifies the application is responding on port 8080
8. Displays deployment completion message

## Directory Structure on EC2

```
~/calculator-app/
├── CalculatorProject-1.0.jar
├── app.pid              # Process ID of running application
└── app.log              # Application output and error logs
```

## Accessing the Application

Once deployed, your Calculator application will be available at:
```
http://<EC2_HOST>:8080
```

### Monitoring Application Status on EC2

SSH into your EC2 instance and run these commands:

```bash
# View application logs (last 30 lines)
tail -30 ~/calculator-app/app.log

# View logs in real-time
tail -f ~/calculator-app/app.log

# Check if process is running
ps aux | grep CalculatorProject

# View the process ID
cat ~/calculator-app/app.pid

# Stop the application
kill $(cat ~/calculator-app/app.pid)

# Check memory usage
free -h
```

## Troubleshooting

### Deployment Fails at SSH Connection
- Verify EC2_SSH_PRIVATE_KEY secret is correctly set
- Ensure EC2 security group allows inbound SSH (port 22) from GitHub Actions runners
- Check that EC2_HOST is correct and reachable
- Run: `ssh -i /path/to/key.pem ec2-user@<EC2_HOST> 'echo connected'`

### JAR File Copy Fails (SCP error)
- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Check EC2 security group allows SSH port 22
- Verify EC2 instance has sufficient disk space: `ssh -i key.pem ec2-user@host 'df -h'`

### Application Fails to Start
- SSH into EC2 and check application logs: `tail -50 ~/calculator-app/app.log`
- Verify Java is installed: `ssh -i key.pem ec2-user@host 'java -version'`
- Check if port 8080 is already in use: `ssh -i key.pem ec2-user@host 'lsof -i :8080'`
- Check available memory: `ssh -i key.pem ec2-user@host 'free -h'`

### Health Check Fails
- Verify application is running: `ps aux | grep CalculatorProject`
- Check application logs for any errors: `tail -f ~/calculator-app/app.log`
- Check EC2 security group allows inbound traffic on port 8080
- Test connectivity: `curl -v http://<EC2_HOST>:8080`

### Old Application Still Running
- The deploy script automatically kills the old process before starting the new one
- If it fails, manually stop it: `ssh -i key.pem ec2-user@host 'kill -9 $(cat ~/calculator-app/app.pid)'`

## Manual Deployment

To manually trigger the workflow without pushing code:
1. Go to Actions tab in your GitHub repository
2. Select "Build and Deploy Calculator to Amazon Linux"
3. Click "Run workflow"
4. Select the branch and click "Run workflow"

## Application Configuration

The application runs with these settings:
- **Port**: 8080 (configurable in deploy step)
- **Memory**: 512MB JVM heap size (configurable with `-Xmx` parameter)
- **Process Management**: Background process with PID file tracking
- **Logging**: All output redirected to `app.log` file

### Customizing JVM Parameters

To adjust JVM memory or other parameters, edit the deploy step in `.github/workflows/deploy-calculator.yml`:

```bash
nohup java -Xmx1024m -Xms512m -jar "$JAR_FILE" \
  --server.port=$APP_PORT \
  > $APP_DIR/app.log 2>&1 &
```

Available options:
- `-Xmx1024m`: Maximum heap size (adjust as needed)
- `-Xms512m`: Initial heap size
- `-Dspring.profiles.active=prod`: Enable production profile (if configured)

## Security Best Practices

1. **SSH Keys**: Keep your EC2_SSH_PRIVATE_KEY secret secure
2. **Network**: Restrict EC2 security group to necessary ports only
3. **Application Port**: Consider using a reverse proxy (nginx) for production
4. **Backups**: Keep backup copies of application JAR files on EC2
5. **Updates**: Keep EC2 instance and Java runtime updated regularly
6. **Logging**: Monitor application logs for errors and issues

## EC2 Instance Setup

Run the provided setup script on your EC2 instance:

```bash
bash setup-ec2.sh
```

Or manually:
```bash
sudo yum update -y
sudo yum install java-21-amazon-corretto-headless curl -y
```

## Next Steps

1. Configure the GitHub secrets as described above
2. Update the EC2 instance hostname in your EC2_HOST secret
3. Push changes to main branch to trigger the first deployment
4. Monitor the Actions tab for workflow execution
5. Access the application at `http://YOUR_EC2_HOST:8080`
6. Check logs regularly for any issues

## Support

For issues with the workflow:
- Check the Actions tab for detailed logs
- Review the workflow YAML syntax in `.github/workflows/deploy-calculator.yml`
- Verify all secrets are correctly configured
- Check EC2 instance connectivity and Java installation
- Review application logs on EC2: `tail -f ~/calculator-app/app.log`
