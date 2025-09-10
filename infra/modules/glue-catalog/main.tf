# AWS Glue Catalog for Data Lake
# Creates Glue databases, tables, and crawlers for data discovery and cataloging

# Main Glue database for the data lake
resource "aws_glue_catalog_database" "data_lake" {
  name        = "${var.project_name}_${var.environment}_data_lake"
  description = "Data lake catalog database for ${var.project_name} ${var.environment} environment"

  # Optional: target database for cross-account access
  # target_database {
  #   catalog_id    = var.catalog_id
  #   database_name = var.target_database_name
  # }

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}_${var.environment}_data_lake"
    Component = "catalog"
    Layer     = "metadata"
  })
}

# Separate database for raw data (before processing)
resource "aws_glue_catalog_database" "raw_data" {
  name        = "${var.project_name}_${var.environment}_raw"
  description = "Raw data catalog for ${var.project_name} ${var.environment} environment"

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}_${var.environment}_raw"
    Component = "catalog"
    Layer     = "raw"
  })
}

# Database for processed/curated data
resource "aws_glue_catalog_database" "processed_data" {
  name        = "${var.project_name}_${var.environment}_processed"
  description = "Processed data catalog for ${var.project_name} ${var.environment} environment"

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}_${var.environment}_processed"
    Component = "catalog"
    Layer     = "processed"
  })
}

# IAM role for Glue crawlers
resource "aws_iam_role" "glue_crawler" {
  name = "${var.project_name}-${var.environment}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-glue-crawler-role"
    Component = "iam"
    Service   = "glue"
  })
}

# Attach AWS managed policy for Glue service
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Custom policy for S3 access
resource "aws_iam_role_policy" "glue_s3_access" {
  name = "${var.project_name}-${var.environment}-glue-s3-policy"
  role = aws_iam_role.glue_crawler.id

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
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws-glue/*"
      }
    ]
  })
}

# Glue crawler for raw data discovery
resource "aws_glue_crawler" "raw_data" {
  name          = "${var.project_name}-${var.environment}-raw-crawler"
  database_name = aws_glue_catalog_database.raw_data.name
  role          = aws_iam_role.glue_crawler.arn
  description   = "Crawler for raw data in ${var.project_name} data lake"

  s3_target {
    path = "s3://${var.data_lake_bucket}/raw/"
  }

  # Run crawler on a schedule (daily at 2 AM)
  schedule = "cron(0 2 * * ? *)"

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
      Tables = {
        AddOrUpdateBehavior = "MergeNewColumns"
      }
    }
  })

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-raw-crawler"
    Component = "crawler"
    Layer     = "raw"
  })
}

# Glue crawler for processed data
resource "aws_glue_crawler" "processed_data" {
  name          = "${var.project_name}-${var.environment}-processed-crawler"
  database_name = aws_glue_catalog_database.processed_data.name
  role          = aws_iam_role.glue_crawler.arn
  description   = "Crawler for processed data in ${var.project_name} data lake"

  s3_target {
    path = "s3://${var.data_lake_bucket}/processed/"
  }

  # Run crawler on a schedule (daily at 3 AM, after raw data processing)
  schedule = "cron(0 3 * * ? *)"

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
      Tables = {
        AddOrUpdateBehavior = "MergeNewColumns"
      }
    }
  })

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-processed-crawler"
    Component = "crawler"
    Layer     = "processed"
  })
}
