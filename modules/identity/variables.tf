variable "name" {
  description = "Le nom de l'identité managée"
  type        = string
}

variable "resource_group_name" {
  description = "Le nom du Resource Group"
  type        = string
}

variable "location" {
  description = "La région Azure"
  type        = string
}

variable "tags" {
  description = "Tags à appliquer à la ressource"
  type        = map(string)
  default     = {}
}