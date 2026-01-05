output "MyRGOutputID" {
  value = data.azurerm_resource_group.myRG.id
}

output "vnet_hub" {
  value = module.hub_network
}

output "vnet_spoke_dev" {
  value = module.spoke_dev_network
}