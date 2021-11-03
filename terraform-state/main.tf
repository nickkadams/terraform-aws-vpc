data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${lower(var.tag_env)}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms" # "AES256"
        kms_master_key_id = var.kms_master_key_id
      }
    }
  }

  # Enable versioning for history of state files
  versioning {
    enabled = true
  }

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false # true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lookup KMS Key ARN by alias
# data "aws_kms_alias" "selected" {
#   name = var.kms_master_key_id
# }

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks_${lower(var.tag_env)}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  server_side_encryption {
    enabled = true
    # kms_key_arn = data.aws_kms_alias.selected.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
