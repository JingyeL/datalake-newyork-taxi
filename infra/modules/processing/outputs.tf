output "processing_role_arn" {
  description = "ARN of the Lambda processing IAM role"
  value       = aws_iam_role.lambda_processing.arn
}

output "step_functions_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = aws_iam_role.step_functions.arn
}

output "data_validator_function_name" {
  description = "Name of the data validator Lambda function"
  value       = aws_lambda_function.data_validator.function_name
}

output "data_validator_function_arn" {
  description = "ARN of the data validator Lambda function"
  value       = aws_lambda_function.data_validator.arn
}

output "data_pipeline_state_machine_arn" {
  description = "ARN of the data pipeline Step Functions state machine"
  value       = aws_sfn_state_machine.data_pipeline.arn
}

output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "step_functions_log_group_name" {
  description = "Name of the Step Functions CloudWatch log group"
  value       = aws_cloudwatch_log_group.step_functions_logs.name
}
