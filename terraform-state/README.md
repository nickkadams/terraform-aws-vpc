# S3 and DynamoDB

Terraform a S3 bucket and DynamoDB table for [Terraform State and Locking](https://www.terraform.io/docs/backends/types/s3.html).

These types of resources are created by default:

* [S3](https://aws.amazon.com/s3/)
* [DynamoDB](https://aws.amazon.com/dynamodb/)
* [Tags](https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html)

## Terraform versions

Terraform 1.1 to 1.5.5.

## Usage

To run this example you need to execute:

```bash
pre-commit install
cp terraform.tfvars.sample terraform.tfvars
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which can cost money (AWS S3, AWS DynamoDB, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 1.5.6 |
| aws | >= 5.40 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.40 |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_id | The ID of the S3 bucket |
| s3\_bucket\_arn | The ID of the S3 bucket |
| dynamodb\_table\_name | The name of the DynamoDB table |
