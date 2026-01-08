resource "azurerm_container_app_environment" "env" {
  name                           = var.environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled

  # Configuration des logs (Optionnel mais recommandé en Prod)
  # log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}