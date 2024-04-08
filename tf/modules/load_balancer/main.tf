resource "yandex_vpc_address" "lb_static_addr" {
  name                = "Load balancer static IP"
  deletion_protection = true
  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_lb_target_group" "k8s_tg" {
  depends_on = [yandex_vpc_address.lb_static_addr]
  name       = "k8s-tg"
  dynamic "target" {
    for_each = var.cluster_nodes
    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "my-network-load-balancer"

  listener {
    name        = "my-http-listener"
    port        = 80
    target_port = 30080

    external_address_spec {
      address    = yandex_vpc_address.lb_static_addr.external_ipv4_address[0].address
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "my-https-listener"
    port        = 443
    target_port = 30443
    external_address_spec {
      address    = yandex_vpc_address.lb_static_addr.external_ipv4_address[0].address
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_tg.id
    healthcheck {
      name = "http"
      http_options {
        port = 30080
        path = "/healthz"
      }
    }
  }
}
