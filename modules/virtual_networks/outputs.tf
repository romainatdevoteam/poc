output "vnet_id" {
  description = "L'ID du Virtual Network créé"
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Le nom du Virtual Network créé"
  value       = azurerm_virtual_network.hub.name
}

output "vnet_address_space" {
  description = "L'espace d'adressage configuré"
  value       = azurerm_virtual_network.hub.address_space
}