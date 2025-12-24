variable "peering_name" {
  description = "Le nom de la relation de peering"
  type        = string
}

variable "resource_group_name" {
  description = "Le nom du Resource Group du VNet SOURCE"
  type        = string
}

variable "virtual_network_name" {
  description = "Le nom du VNet SOURCE"
  type        = string
}

variable "remote_virtual_network_id" {
  description = "L'ID complet du VNet DISTANT (destination)"
  type        = string
}

# --- Options de Configuration Avancées ---

variable "allow_virtual_network_access" {
  description = "Autoriser les VMs des deux réseaux à communiquer"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Autoriser le trafic qui ne provient pas directement du VNet (utile pour les NVA/Firewalls)"
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Autoriser le VNet pairé à utiliser la Gateway de ce VNet (Hub)"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Utiliser la Gateway du VNet pairé (Spoke)"
  type        = bool
  default     = false
}