data "azurerm_resource_group" "myRG" {
  name = "RG-Romain-Rodrigues"
}
data "azurerm_storage_account" "dev_tfstate" {
  name                = "stdevtfstate136874687"               # NOM DE VOTRE ST DU BACKEND
  resource_group_name = data.azurerm_resource_group.myRG.name # RG DE VOTRE BACKEND
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

# Subnet Container Apps
module "subnet_container_apps" {
  source = "./modules/subnets"

  subnet_name          = "snet-container-apps-001"
  resource_group_name  = data.azurerm_resource_group.myRG.name
  virtual_network_name = module.hub_network.vnet_name
  address_prefixes     = ["10.0.50.0/23"] # Minimum /23 requis pour Container Apps

  # Pas de délégation nécessaire pour Container Apps
  delegation = null
}

### ACR ###

module "acr" {
  source = "./modules/acr"

  depends_on = [module.runner_identity]

  name                = "acrghrunnerprod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location

  sku                           = "Standard"
  admin_enabled                 = false
  public_network_access_enabled = true

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
module "runner_acr_push_role" {
  source = "./modules/role_assignments"

  depends_on = [module.acr, module.runner_identity]

  scope                = module.acr.id
  role_definition_name = "AcrPush"
  principal_id         = module.runner_identity.principal_id
}

### GITHUB RUNNER - CONTAINER APP ###

module "github_runner" {
  source = "./modules/container_apps"

  depends_on = [
    module.subnet_container_apps,
    module.runner_identity,
    module.acr,
    module.runner_acr_pull_role
  ]

  name                = "ca-gh-runner-prod"
  environment_name    = "cae-runners-prod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location

  # Réseau
  subnet_id                      = module.subnet_container_apps.id
  internal_load_balancer_enabled = true

  # Identité et ACR
  identity_id      = module.runner_identity.id
  acr_login_server = module.acr.login_server

  # Image
  container_name = "github-runner"
  image          = "${module.acr.login_server}/github-runner:latest"
  cpu            = 2.0
  memory         = "4Gi"

  min_replicas = 0
  max_replicas = 1

  # Variables d'environnement
  environment_variables = {
    "REPO_URL"            = var.github_repo_url
    "RUNNER_NAME"         = "aca-runner-prod"
    "RUNNER_LABELS"       = "self-hosted,linux,azure,production" # Ajoutez ceci
    "EPHEMERAL"           = "0"
    "DISABLE_AUTO_UPDATE" = "1"
  }

  secret_environment_variables = {
    "ACCESS_TOKEN" = var.github_pat_token
  }

  tags = {
    Environment = "Dev"
    Role        = "CI/CD"
    Project     = "GitHub Runner"
  }
}
