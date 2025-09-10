# glue-catalog

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
| [aws_glue_catalog_database.data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_database.processed_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_database.raw_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_crawler.processed_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_glue_crawler.raw_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_iam_role.glue_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.glue_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_data_lake_bucket"></a> [data\_lake\_bucket](#input\_data\_lake\_bucket) | Name of the data lake S3 bucket | `string` | n/a | yes |
| <a name="input_data_lake_bucket_arn"></a> [data\_lake\_bucket\_arn](#input\_data\_lake\_bucket\_arn) | ARN of the data lake S3 bucket | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_crawler_role_arn"></a> [crawler\_role\_arn](#output\_crawler\_role\_arn) | ARN of the Glue crawler IAM role |
| <a name="output_database_arn"></a> [database\_arn](#output\_database\_arn) | ARN of the main Glue catalog database |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the main Glue catalog database |
| <a name="output_processed_crawler_name"></a> [processed\_crawler\_name](#output\_processed\_crawler\_name) | Name of the processed data crawler |
| <a name="output_processed_database_name"></a> [processed\_database\_name](#output\_processed\_database\_name) | Name of the processed data Glue catalog database |
| <a name="output_raw_crawler_name"></a> [raw\_crawler\_name](#output\_raw\_crawler\_name) | Name of the raw data crawler |
| <a name="output_raw_database_name"></a> [raw\_database\_name](#output\_raw\_database\_name) | Name of the raw data Glue catalog database |
<!-- END_TF_DOCS -->
