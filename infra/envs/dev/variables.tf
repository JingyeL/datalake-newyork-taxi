variable "aws_region" {
  description = "AWS region for the data lake infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "data_retention_days" {
  description = "Number of days to retain data in the raw layer"
  type        = number
  default     = 90
}

variable "enable_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption on S3 buckets"
  type        = bool
  default     = true
}
