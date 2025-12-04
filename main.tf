 feature/odochi
locals {
  name = "sock-shop"
}

module "vpc" {
  source = "./module/vpc"
  name   = local.name
}
module "bastion" {
  source      = "./module/bastion"
  name        = local.name
  vpc         = module.vpc.vpc_id
  subnets     = module.vpc.public_subnet_ids
  private_key = module.vpc.private_key
  key_name    = module.vpc.keypair_name
}

module "ansible" {
  source              = "./module/ansible"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  subnet_id           = [module.vpc.private_subnet_ids[0]]
  keypair_name        = module.vpc.keypair_name
  private_key         = module.vpc.private_key
  bastion_sg      = module.bastion.bastion_sg
# VPC Module
module "vpc" {
  source = "./module/vpc"

  name = "k8s_team1"
}

# HAProxy Module
module "haproxy" {
  source = "./module/haproxy"

  name                = "k8s_team1"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  key_name            = module.vpc.keypair_name
  master_private_ips  = var.master_private_ips
}

# Bastion Module
module "bastion" {
  source = "./module/bastion"

  name        = "k8s_team1"
  vpc         = module.vpc.vpc_id
  subnets     = module.vpc.public_subnet_ids
  key_name    = module.vpc.keypair_name
  private_key = module.vpc.private_key
}
