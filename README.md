🚀 Jenkins + Terraform + Docker + RDS Deployment Guide
(Pipeline Script from SCM – Production Setup)

This project deploys a Full Stack Application (Backend + Frontend) using:

✅ AWS RDS (MariaDB)

✅ Terraform (Infrastructure as Code)

✅ Docker (Containerization)

✅ Docker Hub (Image Registry)

✅ Jenkins CI/CD (Pipeline Script from SCM)

All infrastructure and application deployment is automated using a Jenkins pipeline stored inside the GitHub repository.

📌 Prerequisites
🔹 AWS

AWS Account (Free Tier Supported)

IAM user with:

EC2

RDS

VPC

Security Group permissions

Access Key & Secret Key

🔹 Accounts

Docker Hub Account

GitHub Repository:

https://github.com/orion-pax77/EasyCRUD-Docker.git
🟢 STEP 1: Launch EC2 (Ubuntu for Jenkins)

Go to:

AWS Console → EC2 → Launch Instance

Select:

AMI → Ubuntu Server 22.04 LTS

Instance Type → t3.medium

Storage → 20GB

Security Group:

22 (SSH)

8080 (Jenkins)

80 (Frontend)

8080 (Backend)

3306 (Optional – only if RDS public)

Launch instance.

🔹 Connect to EC2
ssh -i your-key.pem ubuntu@your-public-ip
🟢 STEP 2: Install Required Software
🔹 Update System
sudo apt update -y
☕ Install Java (Required for Jenkins)
sudo apt install openjdk-17-jdk -y

Verify:

java -version
🛠 Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y

Start Jenkins:

sudo systemctl start jenkins
sudo systemctl enable jenkins
🔹 Access Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Open in browser:

http://<EC2-PUBLIC-IP>:8080

Install suggested plugins.

🟢 Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

Allow Jenkins to use Docker:

sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
🟢 Install Terraform
sudo apt install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o \
  /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y

Verify:

terraform -version
🟢 Install MySQL Client
sudo apt install mysql-client -y
🟢 STEP 3: Add Credentials in Jenkins

Go to:

Manage Jenkins → Credentials → Global → Add Credentials
✅ 1. AWS Credentials

Kind → AWS Credentials

ID → aws-creds

Add Access Key & Secret Key

✅ 2. RDS Credentials

Kind → Username/Password

ID → rds-creds

Username → admin

Password → redhat123

✅ 3. Docker Hub Credentials

Kind → Username/Password

ID → dockerhub-cred

Add DockerHub username & password

Click Save.

🟢 STEP 4: Create Pipeline (Pipeline Script from SCM)
🔹 1️⃣ Create New Job

Click New Item

Name → easycrud-deployment

Select → Pipeline

Click OK

🔹 2️⃣ Configure Pipeline

Scroll to Pipeline Section

Select:

Definition → Pipeline script from SCM

SCM → Git

Repository URL:
https://github.com/orion-pax77/EasyCRUD-Docker.git
Branch Specifier:
*/main
Script Path:
Jenkinsfile

Click Save

🟢 STEP 5: Run the Pipeline

Click:

Build Now
⚙️ What Happens Automatically
1️⃣ Jenkins Clones GitHub Repository

Pulls code including:

backend/

frontend/

terraform/

Jenkinsfile

2️⃣ Terraform Creates AWS Infrastructure

Default VPC

Security Group

DB Subnet Group

MariaDB RDS Instance

3️⃣ Jenkins Fetches RDS Endpoint

Reads:

terraform output rds_endpoint
4️⃣ Jenkins Creates Database & Table

Creates:

student_db

admin user

students table

5️⃣ Jenkins Updates Backend Configuration

Modifies:

backend/src/main/resources/application.properties

Sets:

RDS endpoint

DB port

Username

Password

MariaDB driver

6️⃣ Jenkins Builds Backend Docker Image
docker build -t backend-image .
7️⃣ Jenkins Runs Backend Container
docker run -d -p 8080:8080 backend-image
8️⃣ Jenkins Updates Frontend Environment

Sets:

BACKEND_URL=http://easycrud1-backend:8080
9️⃣ Jenkins Builds Frontend Docker Image
docker build -t frontend-image .
🔟 Jenkins Runs Frontend Container
docker run -d -p 80:80 frontend-image
1️⃣1️⃣ Jenkins Pushes Images to Docker Hub

Pushes:

Backend image

Frontend image

⏳ Expected Deployment Time

Terraform provisioning: 3–5 minutes

Docker build: 2–3 minutes

Full pipeline: 6–10 minutes

🎯 Final Result

After successful pipeline execution:

✅ AWS RDS Created

✅ Database & Table Created

✅ Backend Running (Port 8080)

✅ Frontend Running (Port 80)

✅ Docker Images Pushed

✅ Fully Automated CI/CD Deployment

🌐 Access Application

Frontend:

http://<EC2-PUBLIC-IP>

Backend:

http://<EC2-PUBLIC-IP>:8080
🛑 To Destroy Infrastructure

Go to Jenkins workspace:

cd /var/lib/jenkins/workspace/easycrud-deployment/terraform
terraform destroy --auto-approve

Or create a separate destroy pipeline.

🏁 Conclusion

This project demonstrates:

Infrastructure as Code (Terraform)

Automated Cloud Deployment

CI/CD using Jenkins (Pipeline Script from SCM)

Containerized Full Stack Application

Production-ready deployment architecture
