# Data Processing Infrastructure
# Creates Lambda functions, Step Functions, and IAM roles for data processing workflows

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_processing" {
  name = "${var.project_name}-${var.environment}-lambda-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-lambda-processing-role"
    Component = "iam"
    Service   = "lambda"
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_processing.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for S3 and Glue access
resource "aws_iam_role_policy" "lambda_data_access" {
  name = "${var.project_name}-${var.environment}-lambda-data-policy"
  role = aws_iam_role.lambda_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.data_lake_bucket_arn,
          "${var.data_lake_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:CreatePartition",
          "glue:UpdatePartition",
          "glue:DeletePartition"
        ]
        Resource = [
          "arn:aws:glue:*:*:database/${var.glue_database}",
          "arn:aws:glue:*:*:table/${var.glue_database}/*",
          "arn:aws:glue:*:*:catalog"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-${var.environment}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-step-functions-role"
    Component = "iam"
    Service   = "step-functions"
  })
}

# Policy for Step Functions to invoke Lambda and Glue
resource "aws_iam_role_policy" "step_functions_execution" {
  name = "${var.project_name}-${var.environment}-step-functions-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:*:*:function:${var.project_name}-${var.environment}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# CloudWatch Log Group for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-processing"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-lambda-logs"
    Component = "logging"
    Service   = "lambda"
  })
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  name              = "/aws/stepfunctions/${var.project_name}-${var.environment}"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-step-functions-logs"
    Component = "logging"
    Service   = "step-functions"
  })
}

# Example Lambda function for data validation
resource "aws_lambda_function" "data_validator" {
  filename      = "placeholder.zip"
  function_name = "${var.project_name}-${var.environment}-data-validator"
  role          = aws_iam_role.lambda_processing.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300

  # Create a placeholder zip file for initial deployment
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
  ]

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      PROJECT_NAME     = var.project_name
      DATA_LAKE_BUCKET = var.data_lake_bucket
      GLUE_DATABASE    = var.glue_database
    }
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-data-validator"
    Component = "processing"
    Service   = "lambda"
  })
}

# Example Step Functions state machine for data pipeline
resource "aws_sfn_state_machine" "data_pipeline" {
  name     = "${var.project_name}-${var.environment}-data-pipeline"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Data processing pipeline for ${var.project_name}"
    StartAt = "ValidateData"
    States = {
      ValidateData = {
        Type     = "Task"
        Resource = aws_lambda_function.data_validator.arn
        Next     = "ProcessData"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleError"
          }
        ]
      }
      ProcessData = {
        Type = "Pass"
        Result = {
          status = "Processing completed successfully"
        }
        End = true
      }
      HandleError = {
        Type = "Pass"
        Result = {
          status = "Error occurred during processing"
        }
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions_logs.arn}:*"
    include_execution_data = false
    level                  = "ERROR"
  }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-data-pipeline"
    Component = "orchestration"
    Service   = "step-functions"
  })
}

# Create placeholder Lambda deployment package
resource "local_file" "lambda_placeholder" {
  content = jsonencode({
    "index.py" = "def handler(event, context):\n    return {'statusCode': 200, 'body': 'Hello from Lambda!'}"
  })
  filename = "${path.module}/lambda_source/index.py"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_source"
  output_path = "${path.module}/placeholder.zip"
  depends_on  = [local_file.lambda_placeholder]
}
