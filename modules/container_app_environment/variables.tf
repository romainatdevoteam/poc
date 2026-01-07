variable "environment_name" {
  description = "Le nom de l'environnement Container Apps (ex: cae-runners-prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Le nom du Resource Group"
  type        = string
}

variable "location" {
  description = "La région Azure (ex: West Europe)"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "L'ID du sous-réseau pour l'intégration VNet"
  type        = string
}

variable "internal_load_balancer_enabled" {
  description = "Si true, l'environnement est accessible uniquement via le VNet (Internal)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Mapping des tags à appliquer"
  type        = map(string)
  default     = {}
}