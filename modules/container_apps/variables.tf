variable "name" {
  description = "Nom du Container App"
  type        = string
}

variable "environment_name" {
  description = "Nom de l'environnement Container Apps"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du resource group"
  type        = string
}

variable "location" {
  description = "Localisation Azure"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet pour l'environnement Container Apps"
  type        = string
}

variable "internal_load_balancer_enabled" {
  description = "Utiliser un load balancer interne"
  type        = bool
  default     = true
}

variable "identity_id" {
  description = "ID de l'identité managée"
  type        = string
}

variable "acr_login_server" {
  description = "Serveur de login ACR (ex: myacr.azurecr.io)"
  type        = string
}

variable "container_name" {
  description = "Nom du container"
  type        = string
  default     = "main"
}

variable "image" {
  description = "Image complète (ex: myacr.azurecr.io/app:latest)"
  type        = string
}

variable "cpu" {
  description = "CPU en cores (0.25, 0.5, 0.75, 1.0, 1.25, etc.)"
  type        = number
  default     = 1.0
}

variable "memory" {
  description = "Mémoire en Gi (0.5, 1.0, 1.5, 2.0, etc.)"
  type        = string
  default     = "2Gi"
}

variable "min_replicas" {
  description = "Nombre minimum de replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Nombre maximum de replicas"
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Variables d'environnement non sensibles"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Variables d'environnement sensibles"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}