hub_vnet_name     = "vnet_hub"
hub_address_space = ["10.0.0.0/16"]

spoke_vnet_name_dev = "vnet_dev"
spoke_address_space = ["10.1.0.0/16"]

runner_delegation = {
  name = "aci-delegation-rule"
  service_delegation = {
    name    = "Microsoft.ContainerInstance/containerGroups"
    actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }
}

github_repo_url = "https://github.com/romainatdevoteam/poc"