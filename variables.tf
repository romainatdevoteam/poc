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
  type = map(object({
    image_name   = string
    image_tag    = string
    cpu          = number
    memory       = string
    min_replicas = number
    max_replicas = number
    env_vars     = optional(map(string), {})
    secrets      = optional(map(string), {})
  }))

  # --- DÉBUT DE LA VALEUR PAR DÉFAUT ---
  default = {
    "demo-web" = {                 # Clé unique (Nom de l'app)
      image_name   = "demo-web-app" # L'image que nous avons importée
      image_tag    = "latest"
      cpu          = 0.25           # Suffisant pour une démo (économique)
      memory       = "0.5Gi"
      min_replicas = 1
      max_replicas = 3              # Autorise le scale-out
      env_vars     = {
        "APP_ENVIRONMENT" = "dev"   # Exemple de variable d'environnement
      }
      secrets      = {}
    }
  }
  # --- FIN DE LA VALEUR PAR DÉFAUT ---
}
