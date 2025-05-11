# Provider configuration is handled in the root terragrunt.hcl file

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
  
  # Convert env map to env list with proper formatting
  env = [for k, v in var.environment_variables : "${k}=${v}"]
  
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
