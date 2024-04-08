data "yandex_vpc_network" "vpc" {
  network_id = var.vpc_id
}

resource "yandex_vpc_security_group" "k8s_security_group" {

  name        = "k8s-ingress-security-group"
  description = "Security group for HTTP and HTTPS for k8s nodes"

  network_id = var.vpc_id

  ingress {
    description    = "HTTP (app -> nginx ingress node port)"
    port           = 30080
    protocol       = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS (app -> nginx ingress node port)"
    port           = 30443
    protocol       = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description    = "Jenkins agent svc"
    port           = 50000
    protocol       = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "k8s_master" {
  count                     = var.master_count
  name                      = "${var.name}-master-${count.index}"
  allow_stopping_for_update = true
  platform_id               = var.master_platform_id
  zone                      = values(var.master_subnets)[count.index % length(var.master_subnets)].zone
  resources {
    cores         = var.master_resources.cores
    memory        = var.master_resources.memory
    core_fraction = var.master_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.master_image_id
      size     = var.master_disk
    }
  }

  scheduling_policy {
    preemptible = var.master_preemptible
  }

  network_interface {
    subnet_id = values(var.master_subnets)[count.index % length(var.master_subnets)].subnet_id
    nat       = false
  }

  metadata = {
    user-data = var.master_user_data
  }
}

resource "yandex_compute_instance" "k8s_node" {
  count                     = var.node_count
  name                      = "${var.name}-node-${count.index}"
  allow_stopping_for_update = true
  zone                      = values(var.node_subnets)[length(var.node_subnets) - count.index % length(var.node_subnets) - 1].zone
  platform_id               = var.node_platform_id
  resources {
    cores         = var.node_resources.cores
    memory        = var.node_resources.memory
    core_fraction = var.node_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.node_image_id
      size     = var.node_disk
    }
  }

  scheduling_policy {
    preemptible = var.node_preemptible
  }

  network_interface {
    subnet_id          = values(var.node_subnets)[length(var.node_subnets) - count.index % length(var.node_subnets) - 1].subnet_id
    nat                = false
    security_group_ids = [data.yandex_vpc_network.vpc.default_security_group_id,  yandex_vpc_security_group.k8s_security_group.id]
  }

  metadata = {
    user-data = var.node_user_data
  }
}

resource "local_file" "inventory_ini" {
  depends_on = [yandex_compute_instance.k8s_master, yandex_compute_instance.k8s_node]
  content    = templatefile("${path.module}/inventory.tftpl", { k8s_hosts = local.k8s_hosts, preserve_newlines = "\r\n" })
  filename   = "${var.output_path}/inventory.ini"
}

resource "null_resource" "nodes_provision" {
  depends_on = [local_file.inventory_ini]

  provisioner "local-exec" {
    command     = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${var.output_path}/inventory.ini ${abspath(path.module)}/provision.yaml"
    on_failure  = continue
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}
