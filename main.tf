data "azurerm_resource_group" "myRG" {
    name = "RG-Romain-Rodrigues"
}

module "hub_network" {
  source = "./modules/virtual_networks"

  vnet_name           = var.hub_vnet_name
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  address_space       = var.hub_address_space
}

module "spoke_network" {
  source = "./modules/virtual_networks"

  vnet_name           = var.spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  address_space       = var.spoke_address_space
}

### PEERINGS ###

# Hub vers Spoke
module "peering_hub_to_spoke" {
  source = "./modules/vnet_peerings"

  peering_name              = "peer-hub-to-spoke"
  resource_group_name       = data.azurerm_resource_group.myRG.name
  virtual_network_name      = module.hub_network.vnet_name
  remote_virtual_network_id = module.hub_network.output.vnet_id

  allow_virtual_network_access = true
  allow_gateway_transit        = true  # Le Hub partage sa Gateway
}

# Spoke vers Hub
module "peering_spoke_to_hub" {
  source = "./modules/vnet_peerings"

  peering_name              = "peer-spoke-to-hub"
  resource_group_name       = data.azurerm_resource_group.myRG.name
  virtual_network_name      = module.spoke_network.vnet_name    # Nom du VNet Spoke
  remote_virtual_network_id = module.spoke_network.output.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Si le trafic passe par un Firewall au Hub
  use_remote_gateways          = true  # Le Spoke utilise la Gateway du Hub
}