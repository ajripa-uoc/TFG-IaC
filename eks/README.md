# EKS Infrastructure as Code (IaC) Project

This repository contains the Infrastructure as Code (IaC) setup for deploying an Amazon Elastic Kubernetes Service (EKS) cluster using Terraform.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project automates the deployment of an EKS cluster with Terraform, including configurations for networking, node groups, IAM roles, and policies.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- An AWS account with sufficient permissions to create EKS, VPC, and IAM resources

## Setup

1. **Clone the repository:**
    ```sh
    git clone https://github.com/yourusername/TFG-IaC.git
    cd TFG-IaC/eks
    ```

2. **Initialize Terraform:**
    ```sh
    terraform init
    ```

3. **Preview the changes (optional but recommended):**
   Before applying, you can use `terraform plan` to review the resources that will be created or modified:
    ```sh
    terraform plan
    ```

4. **Apply the Terraform configuration:**
    ```sh
    terraform apply
    ```
   Confirm with `yes` when prompted to proceed with the deployment.

## Usage

After the EKS cluster is deployed, configure `kubectl` to interact with it:

```sh
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
