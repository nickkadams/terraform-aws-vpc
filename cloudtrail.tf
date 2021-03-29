# data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "trail" {
  bucket = "${lower(var.s3_prefix)}-${lower(var.tag_name)}-trail"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms" # "AES256"
        kms_master_key_id = var.kms_master_key_id
      }
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${lower(var.s3_prefix)}-${lower(var.tag_name)}-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${lower(var.s3_prefix)}-${lower(var.tag_name)}-trail/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY  

  tags = {
    Environment     = var.tag_env
    Contact         = var.tag_cont
    Cost            = var.tag_cost
    Customer        = var.tag_cust
    Project         = var.tag_proj
    Confidentiality = var.tag_conf
    Compliance      = var.tag_comp
    Terraform       = "true"
  }

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false # true
  }
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket = aws_s3_bucket.trail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudtrail" "this" {
  name                          = "${lower(var.tag_name)}-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
}