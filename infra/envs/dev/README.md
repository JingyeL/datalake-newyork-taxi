# dev

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_glue_catalog"></a> [glue\_catalog](#module\_glue\_catalog) | ../../modules/glue-catalog | n/a |
| <a name="module_processing"></a> [processing](#module\_processing) | ../../modules/processing | n/a |
| <a name="module_s3_data_lake"></a> [s3\_data\_lake](#module\_s3\_data\_lake) | ../../modules/s3-datalake | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for the data lake infrastructure | `string` | `"us-east-1"` | no |
| <a name="input_data_retention_days"></a> [data\_retention\_days](#input\_data\_retention\_days) | Number of days to retain data in the raw layer | `number` | `90` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable server-side encryption on S3 buckets | `bool` | `true` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on S3 buckets | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_lake_bucket_arn"></a> [data\_lake\_bucket\_arn](#output\_data\_lake\_bucket\_arn) | ARN of the main data lake S3 bucket |
| <a name="output_data_lake_bucket_name"></a> [data\_lake\_bucket\_name](#output\_data\_lake\_bucket\_name) | Name of the main data lake S3 bucket |
| <a name="output_glue_database_arn"></a> [glue\_database\_arn](#output\_glue\_database\_arn) | ARN of the Glue catalog database |
| <a name="output_glue_database_name"></a> [glue\_database\_name](#output\_glue\_database\_name) | Name of the Glue catalog database |
| <a name="output_processing_role_arn"></a> [processing\_role\_arn](#output\_processing\_role\_arn) | ARN of the data processing IAM role |
<!-- END_TF_DOCS -->
