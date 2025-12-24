variable "hub_vnet_name" {
  type        = string
  description = "Nom du VNET Hub"
}

variable "spoke_vnet_name" {
  type        = string
  description = "Nom du VNET Hub"
}

variable "hub_address_space" {
  type        = list(string)
  description = "CIDR du VNET Hub"
}

variable "spoke_address_space" {
  type        = list(string)
  description = "CIDR du VNET spoke"
}