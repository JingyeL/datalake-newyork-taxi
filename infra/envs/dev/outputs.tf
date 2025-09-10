output "data_lake_bucket_name" {
  description = "Name of the main data lake S3 bucket"
  value       = module.s3_data_lake.data_lake_bucket_name
}

output "data_lake_bucket_arn" {
  description = "ARN of the main data lake S3 bucket"
  value       = module.s3_data_lake.data_lake_bucket_arn
}

output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue_catalog.database_name
}

output "glue_database_arn" {
  description = "ARN of the Glue catalog database"
  value       = module.glue_catalog.database_arn
}

output "processing_role_arn" {
  description = "ARN of the data processing IAM role"
  value       = module.processing.processing_role_arn
}
