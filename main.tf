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

### ACR ###

module "acr" {
  source = "./modules/acr"
  
  depends_on = [module.runner_identity]

  name                = "acrghrunnerprod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location
  
  sku                              = "Standard"
  admin_enabled                    = false
  public_network_access_enabled    = true

  tags = {
    Environment = "Dev"
    Role        = "Container Registry"
    Project     = "GitHub Runner"
  }
}

### ROLE ASSIGNMENTS - ACR ###

# Permet au runner de pull les images depuis l'ACR
module "runner_acr_pull_role" {
  source = "./modules/role_assignments"
  
  depends_on = [module.acr, module.runner_identity]

  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.runner_identity.principal_id
}

# (Optionnel) Permet au runner de push des images dans l'ACR
# Décommenter si tu veux que le runner puisse builder et pusher des images
module "runner_acr_push_role" {
  source = "./modules/role_assignments"
  
  depends_on = [module.acr, module.runner_identity]

  scope                = module.acr.id
  role_definition_name = "AcrPush"
  principal_id         = module.runner_identity.principal_id
}

### ACI - GITHUB RUNNER ###

module "github_runner" {
  source = "./modules/container_instances"
  
  depends_on = [
    module.subnet_runner,
    module.runner_identity,
    module.acr,
    module.runner_acr_pull_role # CRUCIAL : On attend que le droit soit posé
  ]

  name                = "aci-gh-runner-prod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location

  # ATTENTION : Si vous n'avez pas de NAT Gateway sur le Hub,
  # commentez cette ligne pour tester avec une IP Publique temporaire.
  #subnet_ids  = [module.subnet_runner.id]
  
  # On utilise l'identité créée plus haut
  identity_id = module.runner_identity.id

  # Image
  image_name = "${module.acr.login_server}/github-runner:latest"
  
  # Ressources (2 vCPU / 4GB est plus confortable pour des builds CI/CD)
  cpu    = "2.0"
  memory = "4.0"

  environment_variables = {
    "REPO_URL"            = var.github_repo_url
    "RUNNER_NAME"         = "aci-runner-prod"
    "EPHEMERAL"           = "0"
    "DISABLE_AUTO_UPDATE" = "1"
    # Astuce : Si subnet_ids est activé, on force souvent le DNS Google 
    # au cas où le DNS Azure interne ne résout pas vite github.com
    "RUNNER_DNS"          = "8.8.8.8" 
  }

  secure_environment_variables = {
    "ACCESS_TOKEN" = var.github_pat_token
  }
}