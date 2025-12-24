output "vnet_id" {
  description = "L'ID du Virtual Network créé"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Le nom du Virtual Network créé"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "L'espace d'adressage configuré"
  value       = azurerm_virtual_network.this.address_space
}