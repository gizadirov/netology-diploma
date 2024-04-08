resource "yandex_vpc_address" "static_addr" {
  name                = "bastion static IP"
  deletion_protection = true
  external_ipv4_address {
    zone_id = var.zone
  }
}
resource "yandex_compute_instance" "bastion" {
  depends_on  = [yandex_vpc_address.static_addr]
  name        = var.name
  platform_id = var.platform_id
  zone        = var.zone
  resources {
    cores         = var.resources.cores
    memory        = var.resources.memory
    core_fraction = var.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
    }
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  network_interface {
    subnet_id      = var.subnet_id
    nat            = true
    nat_ip_address = yandex_vpc_address.static_addr.external_ipv4_address[0].address
    ip_address     = var.ip_address
  }

  metadata = {
    user-data = var.user_data
  }
}


