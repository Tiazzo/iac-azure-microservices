# TF Infrastructure DevOps

This repository contains the full infrastructure as code (IaC) stack for deploying a microservices-based application using **Terraform** and **Kubernetes** on **Microsoft Azure**.

---

## Stack Overview

- **Terraform**: Manages Azure infrastructure — resource groups, virtual networks, AKS clusters, IPs, and storage.
- **Kubernetes (YAML)**: Manages workloads — deployments, services, config maps, PVCs.
- **Docker & JFrog (optional)**: Container images for microservices.
- **Azure Load Balancer & DNS**: Exposes services to the internet.

---

## Project Structure
terraform/ → Terraform modules and configurations
k8s/ → Kubernetes manifests (organized by microservice)
scripts/ → Utility scripts (init, lint, deploy, etc.)

---

##  Setup Instructions

### 1. Provision Azure Infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```
Ensure your Azure credentials are loaded via Azure CLI or environment variables.

### 2. Deploy Kubernetes Resources
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -R -f k8s/
```
--- 

## Technologies
- Terraform 
- Azure Kubernetes Service (AKS)
- Azure Blob Storage (for remote state)
- Kubernetes
- Docker
- JFrog Artifactory (for private image registry)


