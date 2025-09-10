# s3-datalake

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.temp_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.temp_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.temp_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_data_retention_days"></a> [data\_retention\_days](#input\_data\_retention\_days) | Number of days to retain data in the raw layer | `number` | `90` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on S3 buckets | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_lake_bucket_arn"></a> [data\_lake\_bucket\_arn](#output\_data\_lake\_bucket\_arn) | ARN of the main data lake S3 bucket |
| <a name="output_data_lake_bucket_id"></a> [data\_lake\_bucket\_id](#output\_data\_lake\_bucket\_id) | ID of the main data lake S3 bucket |
| <a name="output_data_lake_bucket_name"></a> [data\_lake\_bucket\_name](#output\_data\_lake\_bucket\_name) | Name of the main data lake S3 bucket |
| <a name="output_temp_processing_bucket_arn"></a> [temp\_processing\_bucket\_arn](#output\_temp\_processing\_bucket\_arn) | ARN of the temporary processing S3 bucket |
| <a name="output_temp_processing_bucket_name"></a> [temp\_processing\_bucket\_name](#output\_temp\_processing\_bucket\_name) | Name of the temporary processing S3 bucket |
<!-- END_TF_DOCS -->
