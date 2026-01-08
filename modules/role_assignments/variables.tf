variable "scope" {
  description = "L'ID de la ressource sur laquelle s'applique le droit (ex: ID du Storage Account, ID de la Subscription)"
  type        = string
}

variable "role_definition_name" {
  description = "Le nom du rôle RBAC (ex: 'Storage Blob Data Contributor')"
  type        = string
}

variable "principal_id" {
  description = "L'ID de l'objet (User, Group, SP, Identity) qui reçoit le droit"
  type        = string
}