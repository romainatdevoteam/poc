output "id" {
  description = "L'ID de la ressource Identity (pour l'attachement)"
  value       = azurerm_user_assigned_identity.identity.id
}

output "principal_id" {
  description = "L'ID du Principal (Object ID) pour les assignations de rôle RBAC"
  value       = azurerm_user_assigned_identity.identity.principal_id
}

output "client_id" {
  description = "Le Client ID de l'identité"
  value       = azurerm_user_assigned_identity.identity.client_id
}