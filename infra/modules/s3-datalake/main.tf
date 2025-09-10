# S3 Data Lake Module
# Creates the foundational S3 buckets for the data lake with proper security and lifecycle policies

# Main data lake bucket with layered structure
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_name}-${var.environment}-data-lake"

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-data-lake"
    Component = "storage"
    Layer     = "data-lake"
  })
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  # Raw data lifecycle (frequent access for recent data)
  rule {
    id     = "raw_data_lifecycle"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }

  # Processed data lifecycle (longer retention in standard)
  rule {
    id     = "processed_data_lifecycle"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }

  # Analytics data lifecycle (keep accessible longer)
  rule {
    id     = "analytics_data_lifecycle"
    status = "Enabled"

    filter {
      prefix = "analytics/"
    }

    transition {
      days          = 180
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }

  # Clean up incomplete multipart uploads
  rule {
    id     = "cleanup_incomplete_uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket for temporary processing data
resource "aws_s3_bucket" "temp_processing" {
  bucket = "${var.project_name}-${var.environment}-temp-processing"

  tags = merge(var.common_tags, {
    Name      = "${var.project_name}-${var.environment}-temp-processing"
    Component = "storage"
    Layer     = "temporary"
  })
}

# Temp bucket - short lifecycle for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "temp_processing" {
  bucket = aws_s3_bucket.temp_processing.id

  rule {
    id     = "temp_data_cleanup"
    status = "Enabled"

    expiration {
      days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Block public access for temp bucket
resource "aws_s3_bucket_public_access_block" "temp_processing" {
  bucket = aws_s3_bucket.temp_processing.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
