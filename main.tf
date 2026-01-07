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

module "container_apps_factory" {
  source = "./modules/container_apps"

  # C'est cette ligne qui transforme le module en boucle
  for_each = var.applications_list

  # GESTION DES DÉPENDANCES (Reste identique)
  depends_on = [
    module.subnet_container_apps,
    module.runner_identity,
    module.acr,
    module.runner_acr_pull_role
  ]

  # 1. NOMMAGE DYNAMIQUE
  # each.key = le nom que tu donnes dans le tfvars (ex: "gh-runner-prod")
  name                = "ca-${each.key}"
  environment_name    = "cae-runners-prod"
  resource_group_name = data.azurerm_resource_group.myRG.name
  location            = data.azurerm_resource_group.myRG.location

  # 2. CONFIGURATION COMMUNE (Infrastructure partagée)
  subnet_id                      = module.subnet_container_apps.id
  internal_load_balancer_enabled = true
  identity_id                    = module.runner_identity.id
  acr_login_server               = module.acr.login_server

  # 3. CONFIGURATION SPÉCIFIQUE (Vient de each.value)
  container_name = "${each.key}-container"

  # Construction de l'URL complète de l'image
  image = "${module.acr.login_server}/${each.value.image_name}:${each.value.image_tag}"

  cpu          = each.value.cpu
  memory       = each.value.memory
  min_replicas = each.value.min_replicas
  max_replicas = each.value.max_replicas

  # 4. GESTION DES VARIABLES D'ENVIRONNEMENT
  # On fusionne ("merge") les variables globales (communes à tous) 
  # avec les variables spécifiques définies dans le tfvars.
  environment_variables = merge(
    {
      "Global_Env"          = "Production"
      "DISABLE_AUTO_UPDATE" = "1"
    },
    each.value.env_vars # Injection des vars spécifiques
  )

  # 5. GESTION DES SECRETS
  # Pareil, on peut avoir des secrets communs (ex: PAT) et des spécifiques
  secret_environment_variables = merge(
    {
      "GITHUB_PAT" = var.github_pat_token # Secret commun (si applicable)
    },
    each.value.secrets
  )

  tags = {
    Environment = "Dev"
    App         = each.key
    ManagedBy   = "Terraform"
  }
}