data "azurerm_resource_group" "myRG" {
  name = "RG-Romain-Rodrigues"
}
data "azurerm_storage_account" "dev_tfstate" {
  name                = "stdevtfstate136874687"       # NOM DE VOTRE ST DU BACKEND
  resource_group_name = data.azurerm_resource_group.myRG.name   # RG DE VOTRE BACKEND
}

### IDENTITY ###

module "runner_identity" {
  source = "./modules/identity"

  name                = "id-gh-runner-prod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  
  tags = {
    Environment = "Dev"
    Role        = "CI/CD"
  }
}

### VNETs ###

module "hub_network" {
  source = "./modules/virtual_networks"

  vnet_name           = var.hub_vnet_name
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  address_space       = var.hub_address_space
}

module "spoke_dev_network" {
  source = "./modules/virtual_networks"

  vnet_name           = var.spoke_vnet_name_dev
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  address_space       = var.spoke_address_space
}

### PEERINGS ###

# Hub vers Spoke
module "peering_hub_to_dev" {
  source = "./modules/vnet_peerings"

  peering_name              = "peer-hub-to-spoke"
  resource_group_name       = data.azurerm_resource_group.myRG.name
  virtual_network_name      = module.hub_network.vnet_name
  remote_virtual_network_id = module.spoke_dev_network.vnet_id

  allow_virtual_network_access = true
  allow_gateway_transit        = true # Le Hub partage sa Gateway
}

# Spoke vers Hub
module "peering_spoke_dev_to_hub" {
  source = "./modules/vnet_peerings"

  peering_name              = "peer-spoke-dev-to-hub"
  resource_group_name       = data.azurerm_resource_group.myRG.name
  virtual_network_name      = module.spoke_dev_network.vnet_name # Nom du VNet Spoke
  remote_virtual_network_id = module.hub_network.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Si le trafic passe par un Firewall au Hub
  use_remote_gateways          = false # Le Spoke utilise la Gateway du Hub
}

# Subnet Runner Github
module "subnet_runner" {
  source = "./modules/subnets"

  subnet_name          = "snet-runners-001"
  resource_group_name  = data.azurerm_resource_group.myRG.name
  virtual_network_name = module.hub_network.vnet_name
  address_prefixes     = ["10.0.1.0/24"]

  # C'est ici que la magie opère : on passe la variable, pas d'objet en dur
  delegation = var.runner_delegation
}

### ACI ###
module "github_runner" {
  depends_on = [ module.subnet_runner,module.runner_identity ]
  source = "./modules/container_instances"

  name                = "aci-gh-runner-prod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location

  # Injection Réseau : Le runner va dans le subnet délégué
  subnet_ids          = [module.subnet_runner.id]

  # Injection Identité : On lie l'identité créée juste au-dessus
  identity_id         = module.runner_identity.id 

  # Configuration de l'image (Best practice : utiliser une image avec Azure CLI pré-installé)
  image_name          = "myoung34/github-runner:latest"
  cpu                 = "1.0"
  memory              = "2.0"

  environment_variables = {
    "REPO_URL"            = "https://github.com/votre-orga/votre-repo"
    "RUNNER_NAME"         = "aci-runner-prod"
    "EPHEMERAL"           = "0"    # 0 = Persistant (redémarre après un job), 1 = Jetable
    "DISABLE_AUTO_UPDATE" = "1"    # Important pour la stabilité réseau
  }

  secure_environment_variables = {
    # La variable doit être définie dans terraform.tfvars ou via TF_VAR_github_pat_token
    "ACCESS_TOKEN" = var.github_pat_token 
  }
}

