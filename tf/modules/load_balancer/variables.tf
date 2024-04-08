variable "zone" {
  type = string
}

variable "cluster_nodes" {
  type = list(object({
    subnet_id = string
    address   = string
  }))
}
