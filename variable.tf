variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair to use for instances"
}

variable "master_private_ips" {
  type        = list(string)
  description = "List of private IP addresses for the Kubernetes master nodes"
  
  validation {
    condition     = length(var.master_private_ips) == 3
    error_message = "Must provide exactly 3 master node private IP addresses."
  }
}
