variable "vnet_name" {
  description = "Le nom du Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Le nom du Resource Group existant où déployer le VNet"
  type        = string
}

variable "location" {
  description = "La région Azure (ex: westeurope)"
  type        = string
}

variable "address_space" {
  description = "La liste des espaces d'adressage (CIDR) du VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"] # Valeur par défaut si non spécifiée
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default     = {}
}