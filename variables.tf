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

variable "applications_list" {
  description = "Catalogue des applications à déployer (Map d'objets)"
  # La clé de la map sera le nom unique de l'application (ex: "runner-prod", "api-backend")
  type = map(object({
    image_name   = string # Nom de l'image dans l'ACR
    image_tag    = string # Tag (v1, latest...)
    cpu          = number # Ex: 0.5 ou 2.0
    memory       = string # Ex: "1Gi" ou "4Gi"
    min_replicas = number
    max_replicas = number
    env_vars     = optional(map(string), {}) # Variables spécifiques (facultatif)
    secrets      = optional(map(string), {}) # Secrets spécifiques (facultatif)
  }))
}
