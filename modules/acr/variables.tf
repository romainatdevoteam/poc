variable "name" {
  description = "Nom de l'Azure Container Registry (doit être globalement unique, alphanumerique uniquement)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Le nom ACR doit contenir entre 5 et 50 caractères alphanumériques uniquement."
  }
}

variable "resource_group_name" {
  description = "Nom du resource group"
  type        = string
}

variable "location" {
  description = "Localisation Azure"
  type        = string
}

variable "sku" {
  description = "SKU de l'ACR : Basic, Standard ou Premium"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Le SKU doit être Basic, Standard ou Premium."
  }
}

variable "admin_enabled" {
  description = "Activer le compte admin (non recommandé en production, utiliser des identités managées)"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Autoriser l'accès public à l'ACR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}