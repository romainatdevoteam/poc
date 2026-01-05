variable "name" {
  description = "Nom du Container Group"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des IDs de subnets (pour injection VNet). Requis pour Private."
  type        = list(string)
  default     = []
}

variable "identity_id" {
  description = "ID de la User Assigned Identity à attacher"
  type        = string
}

variable "image_name" {
  description = "Image Docker (ex: myoung34/github-runner:latest)"
  type        = string
}

variable "cpu" { default = "1.0" }
variable "memory" { default = "2.0" }

variable "environment_variables" {
  description = "Map des variables d'environnement non sensibles"
  type        = map(string)
  default     = {}
}

variable "secure_environment_variables" {
  description = "Map des variables d'environnement sensibles (ex: Token)"
  type        = map(string)
  default     = {}
  sensitive   = true
}