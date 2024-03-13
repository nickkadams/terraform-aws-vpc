variable "aws_profile" {
  default     = "default"
  description = "AWS profile"
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region"
  type        = string
}

variable "aws_network" {
  default     = "172.18.0.0/16"
  description = "AWS base netblock"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "kms_master_key_id" {
  default     = "alias/aws/s3"
  description = "KMS master key ID"
  type        = string
}

variable "tag_name" {
  default     = "services"
  description = "Tag: Name"
  type        = string
}

variable "tag_env" {
  default     = "sandbox"
  description = "Tag: Environment"
  type        = string
}

variable "tag_cont" {
  default     = ""
  description = "Tag: Contact"
  type        = string
}

variable "tag_cost" {
  default     = ""
  description = "Tag: Cost"
  type        = string
}

variable "tag_cust" {
  default     = ""
  description = "Tag: Customer"
  type        = string
}

variable "tag_proj" {
  default     = ""
  description = "Tag: Project"
  type        = string
}

variable "tag_conf" {
  default     = "public"
  description = "Tag: Confidentiality"
  type        = string
}

variable "tag_comp" {
  default     = "CIS"
  description = "Tag: Compliance"
  type        = string
}
