# GitHub Actions Secrets Configuration

This document describes the secrets that need to be configured in the GitHub repository for the CI/CD pipeline to work properly.

## Required Secrets

### AWS Credentials (Development)

- **AWS_ACCESS_KEY_ID**: AWS access key for development environment
- **AWS_SECRET_ACCESS_KEY**: AWS secret key for development environment

### AWS Credentials (Staging) - Optional

- **AWS_ACCESS_KEY_ID_STAGING**: AWS access key for staging environment
- **AWS_SECRET_ACCESS_KEY_STAGING**: AWS secret key for staging environment

### AWS Credentials (Production) - Optional

- **AWS_ACCESS_KEY_ID_PROD**: AWS access key for production environment
- **AWS_SECRET_ACCESS_KEY_PROD**: AWS secret key for production environment

## Setting Up Secrets

1. Go to your GitHub repository
2. Click on **Settings** tab
3. Navigate to **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the appropriate name and value

## IAM Permissions

The AWS credentials should have the following permissions:

### Minimum Required Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "lambda:*",
        "glue:*",
        "states:*",
        "logs:*",
        "events:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"],
      "Resource": "arn:aws:dynamodb:*:*:table/dev-tf-state-locks"
    }
  ]
}
```

## Environment Configuration

### Development Environment

- Automatically deploys on pushes to `main` branch
- Uses `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

### Staging Environment

- Deploys via manual workflow dispatch
- Requires approval through GitHub environments
- Uses `AWS_ACCESS_KEY_ID_STAGING` and `AWS_SECRET_ACCESS_KEY_STAGING`

### Production Environment

- Deploys via manual workflow dispatch
- Requires approval through GitHub environments
- Uses `AWS_ACCESS_KEY_ID_PROD` and `AWS_SECRET_ACCESS_KEY_PROD`

## Security Best Practices

1. **Use IAM Roles**: Consider using IAM roles with OIDC for more secure authentication
2. **Least Privilege**: Only grant the minimum required permissions
3. **Environment Separation**: Use separate AWS accounts for different environments
4. **Secret Rotation**: Regularly rotate access keys
5. **Audit**: Monitor CloudTrail logs for API usage

## Troubleshooting

### Common Issues

1. **Invalid Credentials**

   - Verify the access key and secret key are correct
   - Check if the user has the required permissions

2. **Terraform Backend Access**

   - Ensure the S3 bucket for state exists
   - Verify DynamoDB table for state locking exists
   - Check bucket and table permissions

3. **Resource Creation Failures**
   - Check AWS service limits
   - Verify region-specific permissions
   - Review CloudFormation/Terraform error messages

### Testing Credentials Locally

```bash
# Test AWS credentials
aws sts get-caller-identity

# Test S3 access
aws s3 ls s3://dev-tf-state-nycyellowtaxi

# Test DynamoDB access
aws dynamodb describe-table --table-name dev-tf-state-locks
```
