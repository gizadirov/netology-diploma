output "load_balancer_static_addr" {
  value = yandex_vpc_address.lb_static_addr.external_ipv4_address[0].address
}
