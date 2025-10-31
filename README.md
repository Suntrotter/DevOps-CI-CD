# Terraform Infrastructure — Lesson 5

This project is part of the DevOps CI/CD course and demonstrates modular Terraform configuration with remote (S3) backend setup.

---

## 📁 Project Structure

lesson-5/
│
├── main.tf               # Root Terraform configuration
├── variables.tf          # Global variables
├── outputs.tf            # Global outputs
├── backend.tf            # Backend configuration (S3 + DynamoDB)
│
├── modules/
│   ├── s3-backend/       # Module for creating S3 bucket and DynamoDB table
│   ├── vpc/              # Module for creating VPC, subnets, routes, gateways
│   └── ecr/              # Module for creating Elastic Container Registry (ECR)
│
├── .gitignore            # Ignored files (.terraform, tfstate, etc.)
└── install_dev_tools.sh  # Helper script for local setup

---

## ⚙️ Modules Overview

### **1. s3-backend**
Creates:
- S3 bucket for storing Terraform state  
- DynamoDB table for state locking  
Used to ensure state consistency and collaboration safety.

### **2. vpc**
Creates:
- VPC  
- Private and public subnets  
- Internet and NAT gateways  
Forms the base network infrastructure.

### **3. ecr**
Creates:
- Amazon Elastic Container Registry (ECR) repository  
Used to store Docker images for CI/CD pipelines.

---

## 🚀 Usage Instructions

### 1. Initialize Terraform
```bash
terraform init
````

### 2. Validate Configuration

```bash
terraform validate
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Apply Changes (Create Infrastructure)

```bash
terraform apply
```

### 5. Destroy Infrastructure (Clean up)

```bash
terraform destroy
```

---

## 🪣 Backend Configuration

Remote state can be stored in S3 and locked via DynamoDB.
Backend is defined in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-awesome-lesson5-bucket"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

## 🧹 Cleanup

To remove all AWS resources and avoid extra costs:

```bash
terraform destroy
```

Then manually delete remaining S3 buckets (if any) via AWS Console.

---

## 🧾 Author

**Olena Deineha**
DevOps CI/CD — Lesson 5 (Terraform Modules and Remote Backend)


