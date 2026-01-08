resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # En mode public pour l'instant, on passera en private endpoint plus tard
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}