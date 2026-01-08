resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  ingress {
    # On autorise le trafic depuis internet (variable booléenne)
    external_enabled = var.ingress_external_enabled

    # CRUCIAL : Le port interne du conteneur (sera 80 pour nginx)
    target_port      = var.ingress_target_port

    # Laisse Azure gérer le HTTP/HTTPS automatiquement
    transport        = "auto"

    # Redirige 100% du trafic vers la nouvelle révision
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_login_server
    identity = var.identity_id
  }

  # Déclarer les secrets ici
  dynamic "secret" {
    for_each = var.secret_environment_variables != null ? var.secret_environment_variables : {}
    content {
      name  = lower(replace(secret.key, "_", "-"))
      value = secret.value
    }
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
      dynamic "env" {
        for_each = var.secret_environment_variables != null ? var.secret_environment_variables : {}
        content {
          name        = env.key
          secret_name = lower(replace(env.key, "_", "-"))
        }
      }
    }
  }

  tags = var.tags
}