data "azurerm_resource_group" "myRG" {
    name = "RG-Romain-Rodrigues"
}

module "hub_network" {
  # Chemin relatif vers le dossier du module
  source = "./modules/virtual_networks"

  # Assignation des variables du module avec des valeurs ou des vars globales
  vnet_name           = var.hub_vnet_name
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  address_space       = var.hub_address_space
}