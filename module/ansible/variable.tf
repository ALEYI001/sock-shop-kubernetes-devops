variable "name" {}
variable "vpc_id" {}
variable "subnet_id" { type = list(string) }
variable "keypair_name" {}
variable "private_key" {}  
#variable "s3_bucket_name" {} 
variable "bastion_sg" {}