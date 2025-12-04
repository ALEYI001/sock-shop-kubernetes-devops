variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "master_private_ips" {
  type        = list(string)
  description = "List of private IP addresses for the master nodes"
}
