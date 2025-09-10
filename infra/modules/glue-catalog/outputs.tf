output "database_name" {
  description = "Name of the main Glue catalog database"
  value       = aws_glue_catalog_database.data_lake.name
}

output "database_arn" {
  description = "ARN of the main Glue catalog database"
  value       = aws_glue_catalog_database.data_lake.arn
}

output "raw_database_name" {
  description = "Name of the raw data Glue catalog database"
  value       = aws_glue_catalog_database.raw_data.name
}

output "processed_database_name" {
  description = "Name of the processed data Glue catalog database"
  value       = aws_glue_catalog_database.processed_data.name
}

output "crawler_role_arn" {
  description = "ARN of the Glue crawler IAM role"
  value       = aws_iam_role.glue_crawler.arn
}

output "raw_crawler_name" {
  description = "Name of the raw data crawler"
  value       = aws_glue_crawler.raw_data.name
}

output "processed_crawler_name" {
  description = "Name of the processed data crawler"
  value       = aws_glue_crawler.processed_data.name
}
