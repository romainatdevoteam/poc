output "id" {
  description = "ID de l'Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "name" {
  description = "Nom de l'Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "URL du serveur de login de l'ACR (ex: myacr.azurecr.io)"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "Nom d'utilisateur admin (si admin_enabled = true)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "admin_password" {
  description = "Mot de passe admin (si admin_enabled = true)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}