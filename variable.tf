variable "region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the load balancer"
  default = "aleyi.space"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for Ansible"
  default     = "sock-shop-bkt-aleyi"
}