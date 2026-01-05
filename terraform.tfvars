hub_vnet_name     = "vnet_hub"
hub_address_space = ["10.0.0.0/8"]

spoke_vnet_name_dev = "vnet_spoke"
spoke_address_space = ["10.1.0.0/8"]

runner_delegation = {
  name = "aci-delegation-rule"
  service_delegation = {
    name    = "Microsoft.ContainerInstance/containerGroups"
    actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }
}