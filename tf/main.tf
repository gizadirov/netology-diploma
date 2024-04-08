locals {
  user_data = file("../.secrets/meta.txt")
}

module "vpc" {
  source              = "git::https://github.com/terraform-yc-modules/terraform-yc-vpc"
  labels              = { tag = "diploma" }
  network_description = "terraform-created"
  network_name        = "netology"
  create_vpc          = true
  create_sg           = true
  create_nat_gw       = false
  public_subnets = [
    {
      "v4_cidr_blocks" : ["10.0.10.0/24"],
      "zone" : "ru-central1-a"
    }
  ]
  private_subnets = [
    {
      "v4_cidr_blocks" : ["10.0.20.0/24"],
      "zone" : "ru-central1-a"
    },
    {
      "v4_cidr_blocks" : ["10.0.30.0/24"],
      "zone" : "ru-central1-b"
    },
    {
      "v4_cidr_blocks" : ["10.0.40.0/24"],
      "zone" : "ru-central1-d"
    },
  ]
  routes_private_subnets = [
    {
      destination_prefix : "0.0.0.0/0",
      next_hop_address : var.bastion_internal_ip
    },
  ]
}

module "bastion" {
  source     = "./modules/bastion"
  name       = "bastion-0"
  depends_on = [module.vpc]
  ip_address = var.bastion_internal_ip
  subnet_id  = module.vpc.public_subnets["10.0.10.0/24"].subnet_id
  zone       = module.vpc.public_subnets["10.0.10.0/24"].zone
  user_data  = local.user_data
}

module "k8s" {
  source           = "./modules/k8s"
  depends_on       = [module.bastion]
  vpc_id           = module.vpc.vpc_id
  master_subnets   = module.vpc.private_subnets
  node_subnets     = module.vpc.private_subnets
  master_user_data = local.user_data
  node_user_data   = local.user_data
  output_path      = "${abspath(path.module)}/output"
  bastion_nat_ip   = module.bastion.bastion_static_addr
}


module "registry" {
  source = "./modules/registry"
}

module "load_balancer" {
  source = "./modules/load_balancer"
  zone = module.vpc.public_subnets["10.0.10.0/24"].zone
  cluster_nodes = module.k8s.cluster_nodes
}



