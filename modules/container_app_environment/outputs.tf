output "id" {
  description = "L'ID de l'environnement Container App généré"
  value       = azurerm_container_app_environment.env.id
}

output "default_domain" {
  description = "Le domaine par défaut de l'environnement"
  value       = azurerm_container_app_environment.env.default_domain
}

output "static_ip_address" {
  description = "L'IP statique de l'environnement (Load Balancer)"
  value       = azurerm_container_app_environment.env.static_ip_address
}

output "name" {
  description = "Le nom de l'environnement"
  value       = azurerm_container_app_environment.env.name
}