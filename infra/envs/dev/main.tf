# Data Lake Infrastructure - Development Environment
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "dev-tf-state-nycyellowtaxi"
    key            = "datalake/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "dev-tf-state-locks"
  }
}

# Configure AWS Provider with default tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values for common configurations
locals {
  environment = "dev"
  project     = "nycyellowtaxi-datalake"

  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "terraform"
    Team        = "data"
    Repository  = "JingyeL/datalake-newyork-taxi"
  }
}

# Data Lake Infrastructure Modules
module "s3_data_lake" {
  source = "../../modules/s3-datalake"

  environment  = local.environment
  project_name = local.project
  common_tags  = local.common_tags
}

module "glue_catalog" {
  source = "../../modules/glue-catalog"

  environment          = local.environment
  project_name         = local.project
  common_tags          = local.common_tags
  data_lake_bucket     = module.s3_data_lake.data_lake_bucket_name
  data_lake_bucket_arn = module.s3_data_lake.data_lake_bucket_arn
}

module "processing" {
  source = "../../modules/processing"

  environment          = local.environment
  project_name         = local.project
  common_tags          = local.common_tags
  data_lake_bucket     = module.s3_data_lake.data_lake_bucket_name
  data_lake_bucket_arn = module.s3_data_lake.data_lake_bucket_arn
  glue_database        = module.glue_catalog.database_name
}
