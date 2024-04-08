output "bastion_static_addr" {
  value = yandex_vpc_address.static_addr.external_ipv4_address[0].address
}
