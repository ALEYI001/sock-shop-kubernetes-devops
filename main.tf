locals {
  name = "sock-shop"
}

module "vpc" {
  source = "./module/vpc"
  name   = local.name
  region = var.region
}

module "bastion" {
  source      = "./module/bastion"
  name        = local.name
  vpc         = module.vpc.vpc_id
  subnets     = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  private_key = module.vpc.private_key
  key_name    = module.vpc.keypair_name
}

module "ansible" {
  source              = "./module/ansible"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.private_subnet_ids
  keypair_name        = module.vpc.keypair_name
  private_key         = module.vpc.private_key
  bastion_sg          = module.bastion.bastion_sg
  s3_bucket_name     = var.s3_bucket_name
  master1 = module.master_node.master_node_instance_ip[0]
  master2 = module.master_node.master_node_instance_ip[1]
  master3 = module.master_node.master_node_instance_ip[2]
  haproxy1 = module.haproxy.haproxy_private_ips[0]
  haproxy2 = module.haproxy.haproxy_private_ips[1] 
  worker1 = module.worker_node.worker_instance_ip[0]
  worker2 = module.worker_node.worker_instance_ip[1]
  worker3 = module.worker_node.worker_instance_ip[2]
}

# HAProxy Module
module "haproxy" {
  source = "./module/haproxy"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  key_name            = module.vpc.keypair_name
  master_private_ips  = module.master_node.master_node_instance_ip
}

# worker-node Module
module "worker_node" {
  source = "./module/worker-node"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  key_name            = module.vpc.keypair_name
  bastion_sg          = module.bastion.bastion_sg
  ansible_sg          = module.ansible.ansible_sg
}

# master-node Module
module "master_node" {
  source = "./module/master-node"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  key_name            = module.vpc.keypair_name
  bastion_sg          = module.bastion.bastion_sg
  ansible_sg          = module.ansible.ansible_sg
}

module "stage-lb" {
  source = "./module/stage-lb"
  name                = local.name
  domain_name         = var.domain_name
  vpc_id              = module.vpc.vpc_id
  worker_instance_ids = module.worker_node.worker_instance_ids
  subnets             = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1], module.vpc.public_subnet_ids[2]]
}

module "prod-lb" {
  source = "./module/prod-lb"
  name                = local.name
  domain_name         = var.domain_name
  vpc_id              = module.vpc.vpc_id
  worker_instance_ids = module.worker_node.worker_instance_ids
  subnets             = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1], module.vpc.public_subnet_ids[2]]
}

module "prometheus-lb" {
  source = "./module/prometheus-lb"
  name                = local.name
  domain_name         = var.domain_name
  vpc_id              = module.vpc.vpc_id
  worker_instance_ids = module.worker_node.worker_instance_ids
  subnets             = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1], module.vpc.public_subnet_ids[2]]
}

module "grafana-lb" {
  source = "./module/grafana-lb"
  name                = local.name
  domain_name         = var.domain_name
  vpc_id              = module.vpc.vpc_id
  worker_instance_ids = module.worker_node.worker_instance_ids
  subnets             = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1], module.vpc.public_subnet_ids[2]]
}