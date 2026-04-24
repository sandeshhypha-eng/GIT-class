# 🚀 Manual Deployment of Calculator App on Amazon Linux EC2

This guide explains how to manually build and deploy the Calculator Spring Boot application on an Amazon Linux EC2 instance (without CI/CD).

---

## 📌 Prerequisites

* AWS EC2 instance (Amazon Linux)
* `.pem` key file
* Security Group with **port 22 (SSH)** open
* Internet access on EC2

---

## 🔐 1. Connect to EC2

```bash
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

---

## ⚙️ 2. Install Required Software

```bash
sudo yum update -y

# Install Java 21
sudo yum install -y java-21-amazon-corretto

# Install Maven
sudo yum install -y maven

# Install Git
sudo yum install -y git
```

Verify installation:

```bash
java -version
mvn -version
git --version
```

---

## 📥 3. Clone Repository

```bash
cd ~
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/CalculatorProject
```

---

## 🏗️ 4. Build the Application

```bash
mvn clean package
```

JAR file will be generated in:

```
target/CalculatorProject-*.jar
```

---

## 📁 5. Prepare Deployment Directory

```bash
mkdir -p ~/calculator-app
cp target/CalculatorProject-*.jar ~/calculator-app/app.jar
```

---

## ▶️ 6. Test Run (Optional)

```bash
cd ~/calculator-app
java -jar app.jar
```

Open in browser:

```
http://YOUR_EC2_PUBLIC_IP:8080
```

Stop the app:

```
Ctrl + C
```

---

## ⚙️ 7. Create systemd Service

```bash
sudo nano /etc/systemd/system/calculator.service
```

Paste the following:

```ini
[Unit]
Description=Calculator Spring Boot Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/calculator-app
ExecStart=/usr/bin/java -Xmx512m -jar /home/ec2-user/calculator-app/app.jar --server.port=8080
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

## 🔄 8. Start the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable calculator
sudo systemctl start calculator
```

---

## 🔍 9. Verify Deployment

```bash
sudo systemctl status calculator
```

Check if port is listening:

```bash
ss -tulnp | grep 8080
```

---

## 🔓 10. Allow Port 8080 in AWS

Go to:

**EC2 → Security Groups → Inbound Rules**

Add:

* Type: Custom TCP
* Port: 8080
* Source: 0.0.0.0/0

---

## 🌐 11. Access Application

```
http://YOUR_EC2_PUBLIC_IP:8080
```

---

## 🔁 Updating the Application

```bash
cd ~/YOUR_REPO
git pull

cd CalculatorProject
mvn clean package

cp target/CalculatorProject-*.jar ~/calculator-app/app.jar

sudo systemctl restart calculator
```

---

## ✅ Done!

Your application is now:

* Running as a background service
* Auto-restarting on failure
* Starting on system boot

---

## ⚠️ Troubleshooting

* Check logs:

  ```bash
  journalctl -u calculator -f
  ```
* Restart service:

  ```bash
  sudo systemctl restart calculator
  ```
* Ensure port 8080 is open in Security Group

---
