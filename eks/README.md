# EKS Infrastructure as Code (IaC) Project

This repository contains the Infrastructure as Code (IaC) setup for deploying an Amazon Elastic Kubernetes Service (EKS) cluster.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project automates the deployment of an EKS cluster using Terraform. It includes configurations for networking, node groups, and necessary IAM roles.

## Prerequisites

- AWS CLI installed and configured
- Terraform installed
- kubectl installed
- An AWS account with necessary permissions

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

3. **Apply the Terraform configuration:**
    ```sh
    terraform apply
    ```

## Usage

After the EKS cluster is deployed, you can configure `kubectl` to interact with it:

```sh
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
```