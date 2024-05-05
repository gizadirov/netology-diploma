#common
variable "vpc_id" {
  type = string
}

variable "name" {
  type    = string
  default = "k8s"
}

variable "output_path" {
  type = string
}

variable "bastion_nat_ip" {
  type = string
}

#masters

variable "master_count" {
  type        = string
  default     = 1
  description = "Количество мастер нод"
  validation {
    condition     = var.master_count % 2 != 0 && var.master_count > 0
    error_message = "Значение должно быть нечетным положительным числом."
  }
}

variable "master_resources" {
  type = map(any)
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}

variable "master_preemptible" {
  type        = bool
  default     = false
  description = "Прерываемая"
}

variable "master_platform_id" {
  type    = string
  default = "standard-v3"
}

variable "master_disk" {
  type    = number
  default = 150
}

variable "master_image_id" {
  type    = string
  default = "fd8kp2cfs7pc786lfv2t"
}

variable "master_subnets" {
  type = map(any)
}

variable "master_user_data" {
  type = string
}

#nodes

variable "node_count" {
  type        = string
  default     = 2
  description = "Количество воркер нод"
  validation {
    condition     = var.node_count > 0
    error_message = "Значение должно быть положительным числом больше нуля."
  }
}

variable "node_resources" {
  type = map(any)
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }
}

variable "node_preemptible" {
  type        = bool
  default     = false
  description = "Прерываемая"
}

variable "node_platform_id" {
  type    = string
  default = "standard-v2"
}

variable "node_disk" {
  type    = number
  default = 100
}

variable "node_image_id" {
  type    = string
  default = "fd8kp2cfs7pc786lfv2t"
}

variable "node_subnets" {
  type = map(any)
}

variable "node_user_data" {
  type = string
}
