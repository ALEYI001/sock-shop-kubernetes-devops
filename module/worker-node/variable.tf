variable "name" {
  description = "sock_shop"
  type        = string
}
variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}