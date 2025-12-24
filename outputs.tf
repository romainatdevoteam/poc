output "MyRGOutputID" {
    value = data.azurerm_resource_group.myRG.id
}

output "vnet_hub"{
    value = module.hub_network
}

output "vnet_spoke"{
    value = module.spoke_network
}