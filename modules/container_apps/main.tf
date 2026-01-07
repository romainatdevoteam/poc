resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.identity_id
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    # Déclarer les secrets ici
    dynamic "secret" {
      for_each = var.secret_environment_variables != null ? var.secret_environment_variables : {}
      content {
        name  = secret.key
        value = secret.value
      }
    }

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      # Variables d'environnement classiques
      dynamic "env" {
        for_each = var.environment_variables != null ? var.environment_variables : {}
        content {
          name  = env.key
          value = env.value
        }
      }

      # Variables d'environnement depuis les secrets
      dynamic "env" {
        for_each = var.secret_environment_variables != null ? var.secret_environment_variables : {}
        content {
          name        = env.key
          secret_name = env.key  # ← ICI: utilisez env.key, pas env.value
        }
      }
    }
  }

  tags = var.tags
}