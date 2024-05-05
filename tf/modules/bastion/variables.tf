variable "name" {
  type    = string
  default = "bastion"
}

variable "resources" {
  type = map(any)
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
}

variable "disk" {
  type    = number
  default = 5
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "Прерываемая"
}

variable "platform_id" {
  type    = string
  default = "standard-v2"
}

variable "image_id" {
  type    = string
  default = "fd80mrhj8fl2oe87o4e1"
}

variable "ip_address" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "user_data" {
  type = string
}

