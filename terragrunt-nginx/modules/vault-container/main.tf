# Provider configuration is handled in the root terragrunt.hcl file

resource "docker_image" "vault" {
  name         = "hashicorp/vault:${var.vault_version}"
  keep_locally = true
}

resource "docker_container" "vault" {
  image = docker_image.vault.image_id
  name  = var.container_name
  
  ports {
    internal = 8200
    external = var.external_port
  }

  restart = "always"
  
  # Vault server configuration
  # Development mode for ease of setup (not for real production)
  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=${var.vault_token}",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200"
  ]
  
  capabilities {
    add = ["IPC_LOCK"]
  }

  # Add volume for data persistence if specified
  dynamic "volumes" {
    for_each = var.data_path != "" ? [1] : []
    content {
      container_path = "/vault/data"
      host_path      = var.data_path
      read_only      = false
    }
  }
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terragrunt"
  }
  
  # Health check for Vault
  healthcheck {
    test         = ["CMD", "vault", "status", "-address=http://127.0.0.1:8200"]
    interval     = "10s"
    timeout      = "5s"
    start_period = "5s"
    retries      = 3
  }
}
