variable "subnet_name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "address_prefixes" { type = list(string) }

variable "delegations" {
  description = "Liste des délégations de service pour le subnet."
  type = list(object({
    name = string # Nom arbitraire de la règle de délégation
    service_delegation = object({
      name    = string       # Le nom du service (ex: Microsoft.ContainerInstance/containerGroups)
      actions = list(string) # Les actions autorisées (souvent standard)
    })
  }))
  default = [] # Par défaut : aucune délégation
}