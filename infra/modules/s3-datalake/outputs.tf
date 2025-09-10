output "data_lake_bucket_name" {
  description = "Name of the main data lake S3 bucket"
  value       = aws_s3_bucket.data_lake.bucket
}

output "data_lake_bucket_arn" {
  description = "ARN of the main data lake S3 bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "data_lake_bucket_id" {
  description = "ID of the main data lake S3 bucket"
  value       = aws_s3_bucket.data_lake.id
}

output "temp_processing_bucket_name" {
  description = "Name of the temporary processing S3 bucket"
  value       = aws_s3_bucket.temp_processing.bucket
}

output "temp_processing_bucket_arn" {
  description = "ARN of the temporary processing S3 bucket"
  value       = aws_s3_bucket.temp_processing.arn
}
