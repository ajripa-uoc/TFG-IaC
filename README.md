# TFG-IaC: Infrastructure as Code for GitOps

This repository contains the configurations and templates for implementing Infrastructure as Code (IaC) using Terraform and Helm to deploy applications following the GitOps methodology.

## Description

The goal of this project is to automate the deployment and management of cloud infrastructure and applications on Kubernetes using GitOps principles. The repository integrates tools like Terraform, Helm, ArgoCD, and AWS services such as EKS and EFS to enable a streamlined, declarative deployment process.

### Key Features

- **Infrastructure as Code**: Automate provisioning of cloud resources (EKS, VPC, EFS) with Terraform.
- **GitOps Workflow**: Manage application deployments declaratively with ArgoCD and Helm.
- **CI/CD Integration**: Use GitHub Actions pipelines to automate builds, deployments, and infrastructure lifecycle.
- **Application Templates**: Deploy production-ready applications using reusable Helm charts.

### Tools and Technologies

- **Terraform**: To define and provision infrastructure.
- **ArgoCD**: For GitOps-based application lifecycle management.
- **Helm**: To package and deploy applications on Kubernetes.
- **AWS**: As the cloud provider for scalable and reliable infrastructure.
- **GitHub Actions**: For automation of CI/CD workflows. 

This repository simplifies the deployment of distributed systems, providing reusable components and automating operational tasks to enhance scalability and reliability.
