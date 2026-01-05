resource "azurerm_container_group" "container_instance" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = length(var.subnet_ids) > 0 ? "Private" : "Public"
  os_type             = "Linux"
  subnet_ids          = var.subnet_ids

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  container {
    name   = var.name
    image  = var.image_name
    cpu    = var.cpu
    memory = var.memory

    environment_variables        = var.environment_variables
    secure_environment_variables = var.secure_environment_variables
    
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  restart_policy = "Always"
}