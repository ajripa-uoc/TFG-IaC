# This configuration uses an existing S3 bucket and DynamoDB table created during the bootstrapping phase.
# The S3 bucket stores the Terraform state file, while the DynamoDB table provides state locking.
# Adjust the "key" value for each project to separate and organize state files.

terraform {
    backend "s3" {
        bucket          = "tfg-ajripa-terraform-state"
        key             = "/eks/terraform.tfstate"
        region          = "eu-west-1"
        dynamodb_table  = "tfg-ajripa-terraform-state-lock"
    }
}