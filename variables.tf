variable "hub_vnet_name" {
  type        = string
  description = "Nom du VNET Hub"
}

variable "hub_address_space" {
  type        = list(string)
  description = "CIDR du VNET Hub"
}