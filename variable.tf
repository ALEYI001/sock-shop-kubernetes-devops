variable "region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

<<<<<<< HEAD
variable "master_private_ips" {
  type        = list(string)
  description = "List of private IP addresses for the Kubernetes master nodes"
  
  validation {
    condition     = length(var.master_private_ips) == 3
    error_message = "Must provide exactly 3 master node private IP addresses."
  }
}
variable "domain" {
  default = "edenboutique.space"
=======
variable "domain_name" {
  type        = string
  description = "The domain name for the load balancer"
  default = "work-experience2025.buzz"
>>>>>>> d851546e178927a89ebe6dfa545d65c0df0379a4
}