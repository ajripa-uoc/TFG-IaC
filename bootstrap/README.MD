# TFG-IaC Bootstrap

This repository contains the bootstrap code for the Infrastructure as Code (IaC) project for the Final Degree Thesis (TFG) at Universitat Oberta de Catalunya.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)

## Introduction

Provides foundational setup for deploying infrastructure using IaC principles. It includes scripts and configurations to automate the provisioning of resources.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Basic knowledge of cloud infrastructure and IaC concepts

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/TFG-IaC.git
    cd TFG-IaC/bootstrap
    ```

2. Initialize Terraform:
    ```sh
    terraform init
    ```

## Usage

1. Create a `terraform.tfvars` file to store your configuration variables and modify is as needed:
    ```hcl
    s3_bucket_name      = "tfg-ajripa-terraform-state"
    dynamodb_table_name = "tfg-ajripa-terraform-state-lock"
    aws_region          = "eu-west-1"
    tags = {
        CreatedBy  = "Terraform"
        Owner      = "ajripa@ie.edu"
        Project    = "TFG"
    }
    ```

2. Plan the infrastructure changes:
    ```sh
    terraform plan -var-file="terraform.tfvars"
    ```

3. Apply the changes to deploy the infrastructure:
    ```sh
    terraform apply -var-file="terraform.tfvars"
    ```

This configuration will set up the necessary S3 bucket and DynamoDB table for state management.
