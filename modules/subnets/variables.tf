variable "subnet_name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "address_prefixes" { type = list(string) }

variable "delegation" {
  description = "Configuration de la délégation (Optionnel). Unique par subnet."
  # Notez le changement ici : object(...) et non list(object)
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/action"])
    })
  })
  default = null
}