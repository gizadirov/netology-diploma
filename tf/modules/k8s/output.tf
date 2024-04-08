output "cluster_nodes" {
  value = [for node in yandex_compute_instance.k8s_node : {
    subnet_id = node.network_interface[0].subnet_id
    address   = node.network_interface[0].ip_address
  }]
}
