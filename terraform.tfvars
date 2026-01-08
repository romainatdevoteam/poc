hub_vnet_name     = "vnet_hub"
hub_address_space = ["10.0.0.0/16"]

spoke_vnet_name_dev = "vnet_dev"
spoke_address_space = ["10.1.0.0/16"]

runner_delegation = {
  name = "aci-delegation-rule"
  service_delegation = {
    name    = "Microsoft.ContainerInstance/containerGroups"
    actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }
}

github_repo_url = "https://github.com/romainatdevoteam/poc"

applications_list = {

  # APP 1 : Ton Runner GitHub (Gros CPU, toujours UP)
  "gh-runner-prod" = {
    image_name   = "github-runner"
    image_tag    = "latest"
    cpu          = 0.25
    memory       = "0.5Gi"
    min_replicas = 1
    max_replicas = 1

    env_vars = {
      "RUNNER_LABELS" = "self-hosted,linux,azure"
      "REPO_URL"      = "https://github.com/ton-orga/ton-repo"
    }
  },

  # APP 2 : Une petite API interne (Petit CPU, Scale to Zero)
  "mon-api-interne" = {
    image_name   = "hello-world" # Doit exister dans l'ACR
    image_tag    = "latest"
    cpu          = 0.25
    memory       = "0.5Gi"
    min_replicas = 1
    max_replicas = 4

    env_vars = {
      "LOG_LEVEL" = "DEBUG"
    }

    secrets = {
      "DB_PASSWORD" = "super-secret-password"
    }
  }
}