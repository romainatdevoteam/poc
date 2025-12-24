output "peering_id" {
  description = "L'ID de la ressource de peering créée"
  value       = azurerm_virtual_network_peering.vnet_peering.id
}

output "peering_name" {
  description = "Le nom du peering"
  value       = azurerm_virtual_network_peering.vnet_peering.name
}