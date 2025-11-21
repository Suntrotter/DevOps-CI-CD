# Lesson 8–9 — AWS EKS + Jenkins + Argo CD CI/CD (Django App)

This project is part of the DevOps CI/CD course and demonstrates how to build a simple GitOps-based CI/CD pipeline on AWS using **Terraform**, **EKS**, **Jenkins**, **Kaniko**, **ECR**, **Helm**, and **Argo CD**.

Infrastructure and tools are provisioned automatically with Terraform modules. A Django application is packaged as a Helm chart.  
The flow:

1. Terraform creates VPC, EKS cluster, ECR, Jenkins and Argo CD.
2. Jenkins (running in Kubernetes) builds a Docker image with Kaniko and pushes it to ECR.
3. Jenkins updates the image tag in the Django Helm chart `values.yaml` and pushes changes to `main`.
4. Argo CD watches the Helm chart in Git and automatically syncs changes to the EKS cluster.

---

## Project Structure

Repository structure relevant for Lesson 8–9:

```text
.
├── backend.tf              # Terraform remote backend (S3 + DynamoDB)
├── main.tf                 # Root Terraform config: calls all modules
├── outputs.tf              # Global Terraform outputs
├── modules/                # Terraform modules
│   ├── s3-backend/         # S3 bucket + DynamoDB table for Terraform state
│   ├── vpc/                # VPC, subnets, routing, IGW/NAT
│   ├── ecr/                # ECR repository for Django images
│   ├── eks/                # EKS cluster + node group + CSI driver
│   ├── jenkins/            # Helm release for Jenkins in K8s
│   └── argo_cd/            # Helm release for Argo CD + Argo applications
│
└── lesson-7/
    ├── app/                # Django application sources (used to build image)
    └── charts/
        └── django-app/     # Helm chart for the Django app
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── deployment.yaml
                ├── service.yaml
                ├── httproute.yaml / ingress.yaml
                ├── hpa.yaml
                └── configmap.yaml

## Prerequisites

Before running Terraform, you need:

AWS account and IAM user with permissions for EKS, ECR, VPC, S3, DynamoDB, ELB.

AWS CLI configured locally (aws configure).

Terraform >= 1.6.

kubectl, helm, and git.

Docker installed locally (for testing builds — optional).

Region and other variables are configured in variables.tf and terraform.tfvars (if used).

## 1. Provisioning Infrastructure with Terraform

From the repository root:

terraform init
terraform plan
terraform apply


Terraform will:

Create / reuse S3 + DynamoDB for remote state.

Create VPC, subnets, routing, and security groups.

Create ECR repository for the Django app.

Create EKS cluster and managed node group.

Install Jenkins via Helm.

Install Argo CD via Helm and create Argo CD Applications for the Django Helm chart.

After terraform apply finishes, pay attention to the outputs:

cluster_name — EKS cluster name

cluster_endpoint — EKS API server URL

jenkins_url — external URL for Jenkins (LoadBalancer)

argocd_url — external URL for Argo CD (LoadBalancer)

ecr_repo_url — ECR repository URL for the Django image

Configure kubectl
aws eks update-kubeconfig --name <cluster_name> --region <aws_region>
kubectl get nodes


You should see worker nodes in Ready state.

## 2. Jenkins Setup and Pipeline

Jenkins is installed in the Kubernetes cluster via the modules/jenkins Terraform module (Helm release).
Namespace: usually jenkins (see module variables).

Access Jenkins

Open the URL from the Terraform output jenkins_url
or run port-forward:

kubectl port-forward -n jenkins svc/jenkins 8080:8080


Admin password can be obtained from Terraform output or directly from Kubernetes:

kubectl -n jenkins get secret jenkins \
  -o jsonpath="{.data.jenkins-admin-password}" | base64 -d


Log in as admin.

Jenkins Pipeline

The Jenkins pipeline (Jenkinsfile) does the following:

Checkout the application sources (this repository and/or a separate app repo).

Runs on a Kubernetes agent with Kaniko, using the EKS cluster as build environment.

Build Docker image for the Django app from the Dockerfile.

Push image to ECR (credentials and repo URL are provided via environment variables/credentials).

Update image tag in the Django Helm chart values.yaml
(for example lesson-7/charts/django-app/values.yaml).

Commit and push the updated values.yaml back to the main branch of the Helm chart repo.

To trigger the pipeline:

Configure a multibranch or pipeline job in Jenkins.

Point it to the Git repository and the Jenkinsfile.

Run Build Now and wait until all stages are green.

## 3. Argo CD and GitOps Deployment

Argo CD is installed using the modules/argo_cd Terraform module (Helm release in the argocd namespace).

Access Argo CD

Open the URL from Terraform output argocd_url,
or port-forward:

kubectl port-forward -n argocd svc/argocd-server 8081:443


Initial admin password (if not overridden in values.yaml):

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d


Login as admin.

Argo CD Application

Terraform creates an Argo CD Application that:

Watches the Helm chart repo (path to django-app chart).

Uses the EKS cluster as destination.

Has auto-sync enabled.

After Jenkins updates and pushes the new image tag to values.yaml, Argo CD:

Detects the commit in Git.

Marks the Application as OutOfSync.

Automatically applies the new revision to the cluster (status Synced, Healthy).

You can verify status in the Argo CD UI or via CLI:

argocd app list
argocd app get django-app

## 4. How to Verify the End-to-End Pipeline

Run terraform apply and make sure all modules succeed.

Check that EKS nodes are Ready:

kubectl get nodes


Open Jenkins, run the pipeline, and confirm that:

Docker image is built and visible in ECR with a new tag.

values.yaml in the Helm chart repo contains the new image tag.

Open Argo CD and ensure the django-app Application is Synced and Healthy.

Check deployment in Kubernetes:

kubectl get pods -n django
kubectl get svc  -n django


Open the Django service via LoadBalancer or port-forward and verify that the app is running.

## 5. Cleanup

To remove all AWS resources created by this lesson:

terraform destroy


Make sure no important data remains in ECR/S3 before destroying the stack.