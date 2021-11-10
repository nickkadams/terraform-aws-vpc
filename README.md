# Terraform AWS VPC

Terraform a 3-AZ VPC in AWS using the [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) module.

These types of resources are created by default:

* [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
* [Subnet](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
* [Route table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)
* [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
* [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
* [VPC Flow Log](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
* [VPC Endpoint](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html):
  * Gateway: S3, DynamoDB

* [RDS DB Subnet Group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets)
* [ElastiCache Subnet Group](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/SubnetGroups.html)
* [DHCP Options Set](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html)
* [Elastic IP addresses](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)
* [Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
* [Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-private.html)
* [Tags](https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html)

## Terraform versions

Terraform 1.0 and newer.

## Usage

To run this example you need to execute:

```bash
pre-commit install
cp terraform.tfvars.sample terraform.tfvars
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, AWS NAT Gateway, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0|
| aws | >= 3.64 |
| vpc | >= 3.11|
| security-group | >= 4.4 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.64 |

## Modules

| Name | Version |
|------|---------|
| vpc | >= 3.11|
| security-group | >= 4.4 |

## Inputs

| Name | Description |
|------|-------------|
| domain\_name | Specifies DNS name for DHCP options set and Route 53 private hosted zone |

## Outputs

| Name | Description |
|------|-------------|
| account\_id | The AWS account ID |
| caller\_arn | The caller ARN |
| vpc\_id | The ID of the VPC |
| vpc\_name | The name of the VPC |
| vpc\_cidr\_block | The CIDR block of the VPC |
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| rds\_subnet\_group | The RDS DB subnet group |
| ec\_subnet\_group | The ElastiCache subnet group |
| mgmt\_security\_group | The management security group |
| jumphost\_eips | List of elastic IPs |
| domain\_name | The Route 53 domain name |

## Authors

Code is maintained by [Nick Adams](https://github.com/nickkadams) with modules from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-vpc/graphs/contributors). Linting best practices from [Kerim Satirli](https://github.com/ksatirli/code-quality-for-terraform).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/nickkadams/terraform-aws-vpc/blob/main/LICENSE) for full details.
