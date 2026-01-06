resource "azurerm_container_app_environment" "env" {
  name                       = var.environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  infrastructure_subnet_id   = var.subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled

  tags = var.tags
}

resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  # ⭐ Configuration pour utiliser l'identité managée pour pull depuis ACR
  registry {
    server   = var.acr_login_server
    identity = var.identity_id  # Utilise l'identité managée pour s'authentifier
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      # Variables d'environnement
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Variables sécurisées
      dynamic "env" {
        for_each = var.secure_environment_variables
        content {
          name        = env.key
          secret_name = replace(lower(env.key), "_", "-")
        }
      }
    }
  }

  # Secrets pour les variables sécurisées
  dynamic "secret" {
    for_each = var.secure_environment_variables
    content {
      name  = replace(lower(secret.key), "_", "-")
      value = secret.value
    }
  }

  tags = var.tags
}