output "registry_id" {
  value = module.registry.registry_id
}
output "bastion_static_addr" {
  value = module.bastion.bastion_static_addr
}
output "lb_static_addr" {
  value = module.load_balancer.load_balancer_static_addr
}