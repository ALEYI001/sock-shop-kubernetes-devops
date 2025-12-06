variable "region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the load balancer"
  default = "work-experience2025.buzz"
}