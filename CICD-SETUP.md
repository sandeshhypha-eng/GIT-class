# CI/CD Setup and Troubleshooting

## GitHub Actions Workflow

The workflow in `.github/workflows/deploy-to-ec2.yml` automatically:
1. Builds the JAR on every push to `main`
2. Deploys the JAR to your EC2 instance
3. Installs Java (if missing)
4. Deploys and restarts the systemd service
5. Runs a smoke test

## Required Secrets Setup

Go to **GitHub > Settings > Secrets and variables > Actions** and add these:

### 1. `SSH_PRIVATE_KEY`
Your EC2 SSH private key, **including line breaks**.

**Recommended approach:**
```bash
# On your local machine, print the private key with line breaks preserved
cat ~/.ssh/your-ec2-key.pem
```

Copy the entire output (including `-----BEGIN` and `-----END` lines) and paste it as the secret value in GitHub.

**If using OpenSSH format (newer), convert first:**
```bash
ssh-keygen -p -m pem -f ~/.ssh/your-ec2-key.pem
```

### 2. `SERVER_IP`
The public IP or hostname of your EC2 instance.
```
203.0.113.42
```

### 3. `SERVER_USER`
The SSH user for your EC2 instance (usually `ec2-user` for Amazon Linux, `ubuntu` for Ubuntu, etc.).
```
ec2-user
```

## EC2 Setup

1. **Ensure SSH access works locally:**
```bash
ssh -i ~/.ssh/your-ec2-key.pem ec2-user@203.0.113.42 "echo Connected"
```

2. **Ensure sudoers is set up (no password prompt):**
```bash
# On EC2:
sudo visudo
# Verify: ec2-user ALL=(ALL) NOPASSWD: ALL
```

3. **Pre-create directories** (optional, workflow will create them):
```bash
ssh -i ~/.ssh/your-ec2-key.pem ec2-user@203.0.113.42 << 'EOF'
sudo mkdir -p /opt/calculator /var/log/calculator
sudo chown -R ec2-user:ec2-user /opt/calculator /var/log/calculator
EOF
```

## Troubleshooting SSH Key Issues

### Error: `Permission denied (publickey,...)`

**Symptom:**
```
scp: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
scp: Connection closed
```

**Fixes:**

1. **Verify the key format** — GitHub secrets need literal newlines. If you copy-pasted from a single-line format, it won't work.
   - Use: `cat ~/.ssh/your-ec2-key.pem` and copy the **entire output** with all newlines.

2. **Verify the EC2 security group** allows port 22 inbound from GitHub runners (or all):
   - Go to EC2 Dashboard > Security Groups > Inbound rules
   - Ensure SSH (port 22) is open to at least `0.0.0.0/0`

3. **Test the key locally first:**
```bash
ssh -i ~/.ssh/your-ec2-key.pem -v ec2-user@203.0.113.42 "echo OK"
```
Look for auth failures or key issues in verbose output.

4. **Regenerate the key if unsure:**
   - Create a new EC2 key pair in AWS console
   - Download it locally
   - Add to GitHub secrets
   - Terminate old instances or update authorized_keys

### Error: `Host key verification failed`

Workflow already runs `ssh-keyscan`, but if issues persist:
- Ensure `ssh-keyscan` succeeded (check workflow logs)
- Verify SERVER_IP is correct and reachable

## Manual Test

To test deployment manually without pushing to GitHub:

```bash
# On local machine
export SERVER_IP=203.0.113.42
export SERVER_USER=ec2-user

# Build jar
mvn -B -f CalculatorProject/pom.xml clean package -DskipTests

# Copy jar and systemd unit
scp -i ~/.ssh/your-ec2-key.pem CalculatorProject/target/CalculatorProject-1.0.jar "$SERVER_USER"@"$SERVER_IP":/tmp/
scp -i ~/.ssh/your-ec2-key.pem CalculatorProject/systemd/calculator.service "$SERVER_USER"@"$SERVER_IP":/tmp/

# Deploy
ssh -i ~/.ssh/your-ec2-key.pem "$SERVER_USER"@"$SERVER_IP" << 'EOF'
sudo mkdir -p /opt/calculator /var/log/calculator
sudo mv /tmp/CalculatorProject-1.0.jar /opt/calculator/
sudo mv /tmp/calculator.service /etc/systemd/system/
sudo chown -R root:root /opt/calculator /etc/systemd/system/calculator.service
sudo systemctl daemon-reload
sudo systemctl enable --now calculator.service
sleep 2
curl http://localhost:8080/ | head -20
EOF
```

## Checking Deployment Status

After push or workflow trigger:

```bash
# View workflow logs in GitHub Actions
# or SSH into EC2 and check:

ssh -i ~/.ssh/your-ec2-key.pem ec2-user@203.0.113.42

# Check service status
sudo systemctl status calculator.service

# View logs
sudo journalctl -u calculator.service -f

# Check if port 8080 is listening
sudo ss -tlnp | grep 8080

# Test endpoint
curl http://localhost:8080/
```

## Next Steps (Optional)

- Add a Slack notification on deployment success/failure
- Add a step to upload release notes to GitHub Releases
- Implement rolling deployments or blue-green if you add a load balancer
- Add metrics/monitoring (CloudWatch, Prometheus, etc.)
