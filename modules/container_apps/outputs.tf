output "id" {
  description = "ID du Container App"
  value       = azurerm_container_app.app.id
}

output "name" {
  description = "Nom du Container App"
  value       = azurerm_container_app.app.name
}

output "environment_id" {
  description = "ID de l'environnement Container Apps"
  value       = azurerm_container_app_environment.env.id
}

output "fqdn" {
  description = "FQDN du Container App"
  value       = azurerm_container_app.app.latest_revision_fqdn
}