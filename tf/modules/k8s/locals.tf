locals {
  k8s_hosts = {
    master_hosts   = yandex_compute_instance.k8s_master
    node_hosts     = yandex_compute_instance.k8s_node
    bastion_nat_ip = var.bastion_nat_ip
  }
}

