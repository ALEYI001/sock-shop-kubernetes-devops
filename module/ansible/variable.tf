variable "name" {}
variable "vpc_id" {}
variable "subnet_id" { type = list(string) }
variable "keypair_name" {}
variable "private_key" {}  
variable "s3_bucket_name" {} 
variable "bastion_sg" {}
variable "master1" {}
variable "master2" {}
variable "master3" {}
variable "haproxy1" {}
variable "haproxy2" {}
variable "worker1" {}
variable "worker2" {}  
variable "worker3" {}