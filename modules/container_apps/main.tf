resource "azurerm_container_app_environment" "env" {
  name                           = var.environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = var.subnet_id
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

  registry {
    server   = var.acr_login_server
    identity = var.identity_id
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables != null ? var.environment_variables : {}
        content {
          name  = env.key
          value = env.value
        }
      }
      dynamic "secure_env" {
        for_each = var.secret_environment_variables != null ? var.secret_environment_variables : {}
        content {
          name  = secure_env.key
          value = secure_env.value
        }
      }
    }
  }

  tags = var.tags
}