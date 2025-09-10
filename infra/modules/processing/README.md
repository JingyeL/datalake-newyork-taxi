# processing

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.12.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.step_functions_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.lambda_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.step_functions_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.data_validator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_sfn_state_machine.data_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [local_file.lambda_placeholder](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_data_lake_bucket"></a> [data\_lake\_bucket](#input\_data\_lake\_bucket) | Name of the data lake S3 bucket | `string` | n/a | yes |
| <a name="input_data_lake_bucket_arn"></a> [data\_lake\_bucket\_arn](#input\_data\_lake\_bucket\_arn) | ARN of the data lake S3 bucket | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_glue_database"></a> [glue\_database](#input\_glue\_database) | Name of the Glue catalog database | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_pipeline_state_machine_arn"></a> [data\_pipeline\_state\_machine\_arn](#output\_data\_pipeline\_state\_machine\_arn) | ARN of the data pipeline Step Functions state machine |
| <a name="output_data_validator_function_arn"></a> [data\_validator\_function\_arn](#output\_data\_validator\_function\_arn) | ARN of the data validator Lambda function |
| <a name="output_data_validator_function_name"></a> [data\_validator\_function\_name](#output\_data\_validator\_function\_name) | Name of the data validator Lambda function |
| <a name="output_lambda_log_group_name"></a> [lambda\_log\_group\_name](#output\_lambda\_log\_group\_name) | Name of the Lambda CloudWatch log group |
| <a name="output_processing_role_arn"></a> [processing\_role\_arn](#output\_processing\_role\_arn) | ARN of the Lambda processing IAM role |
| <a name="output_step_functions_log_group_name"></a> [step\_functions\_log\_group\_name](#output\_step\_functions\_log\_group\_name) | Name of the Step Functions CloudWatch log group |
| <a name="output_step_functions_role_arn"></a> [step\_functions\_role\_arn](#output\_step\_functions\_role\_arn) | ARN of the Step Functions IAM role |
<!-- END_TF_DOCS -->
