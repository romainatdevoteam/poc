variable "hub_vnet_name" {
  type        = string
  description = "Nom du VNET Hub"
}

variable "spoke_vnet_name_dev" {
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

# root/variables.tf

variable "runner_delegation" {
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

variable "github_pat_token" {
  type      = string
  sensitive = true
}

variable "github_repo_url" {
  type = string
}