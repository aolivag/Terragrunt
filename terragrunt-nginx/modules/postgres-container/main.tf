# Provider configuration is handled in the root terragrunt.hcl file

# Optional Vault provider configuration
provider "vault" {
  address         = var.vault_address
  token           = var.vault_token
  skip_tls_verify = true

  # Only configure if we're actually using Vault
  alias = "postgres_secrets"
}

# Get the password from Vault if use_vault is true
data "vault_generic_secret" "postgres_password" {
  count     = var.use_vault && var.vault_secret_path != "" ? 1 : 0
  path      = var.vault_secret_path
  provider  = vault.postgres_secrets
}

locals {
  # Use password from Vault if available, otherwise use the one provided in variables
  effective_password = var.use_vault && var.vault_secret_path != "" && length(data.vault_generic_secret.postgres_password) > 0 ? data.vault_generic_secret.postgres_password[0].data["password"] : var.postgres_password

  # Create environment variables map with password injected from Vault if configured
  env_with_password = merge(var.environment_variables, {
    "POSTGRES_PASSWORD" = local.effective_password
  })
}

resource "docker_image" "postgres" {
  name         = "postgres:${var.postgres_version}"
  keep_locally = true
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = var.container_name
  
  ports {
    internal = 5432
    external = var.external_port
  }

  restart = "always"
    # Convert env map to env list with proper formatting including the password from Vault if configured
  env = [for k, v in local.env_with_password : "${k}=${v}"]
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terragrunt"
  }
  
  # Add volume for data persistence if specified
  dynamic "volumes" {
    for_each = var.data_path != "" ? [1] : []
    content {
      container_path = "/var/lib/postgresql/data"
      host_path      = var.data_path
      read_only      = false
    }
  }
  
  # Health check for PostgreSQL
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.postgres_user} -d ${var.postgres_db}"]
    interval     = "30s"
    timeout      = "10s"
    start_period = "10s"
    retries      = 3
  }
}
