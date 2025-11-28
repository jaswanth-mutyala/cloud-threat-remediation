# 🛡️ Automated Cloud Threat Remediation System

## 📌 Project Overview
This project implements an **Event-Driven Security** architecture on AWS. It automatically detects and quarantines compromised EC2 instances in real-time, reducing the **Mean Time to Respond (MTTR)** from hours to seconds.

Instead of relying on manual monitoring, this system uses **Infrastructure as Code (IaC)** to deploy a honeypot environment and a **DevSecOps pipeline** to ensure security best practices before deployment.

### 🎯 Key Features
* **Infrastructure as Code:** Fully automated deployment using **Terraform**.
* **Real-time Threat Detection:** Uses **AWS GuardDuty** to identify malicious activity (e.g., SSH Brute Force, Port Scans).
* **Automated Remediation:** **AWS EventBridge** triggers a **Lambda (Python)** function to isolate compromised instances instantly.
* **DevSecOps Integration:** CI/CD pipeline with **GitHub Actions** and **Checkov** to scan Terraform code for misconfigurations.
* **Notification:** SNS alerts sent to security teams immediately upon remediation.

---

## 🏗️ Architecture
**The Flow:**
1.  **Attacker** scans the "Honeypot" EC2 instance (deliberately exposed).
2.  **GuardDuty** detects the malicious traffic patterns.
3.  **EventBridge** captures the finding and triggers the remediation Lambda.
4.  **Lambda** removes the compromised Security Group and attaches a "Forensics/Quarantine" group (Deny All).
5.  **SNS** notifies the administrator via email.

![Architecture Diagram](docs/images/architecture-diagram.png)

---


---

## 🛠️ Tech Stack
| Category | Technology |
| :--- | :--- |
| **Cloud Provider** | AWS (EC2, VPC, IAM, S3, GuardDuty, EventBridge, SNS) |
| **IaC** | Terraform |
| **Automation** | Python (Boto3) |
| **CI/CD** | GitHub Actions |
| **Security Scanning** | Checkov |

---

## 🚀 How to Deploy

### 1. Prerequisites
* AWS CLI configured with Admin permissions.
* Terraform installed.

### 2. Deployment
Clone the repository and initialize Terraform:
```bash
git clone [https://github.com/YOUR_USERNAME/cloud-threat-remediation.git](https://github.com/YOUR_USERNAME/cloud-threat-remediation.git)
cd cloud-threat-remediation/terraform
terraform init
terraform plan
terraform apply --auto-approve
