# Output the name of the S3 bucket used for storing the Terraform state file.
output "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  value       = module.s3.bucket_id
}

# Output the ARN of the S3 bucket for direct references in IAM policies or other configurations.
output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for storing Terraform state"
  value       = module.s3.arn
}

# Output the name of the DynamoDB table used for Terraform state locking.
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = module.dynamodb.name
}

# Output the ARN of the DynamoDB table for permissions and policy configurations.
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for Terraform state locking"
  value       = module.dynamodb.arn
}