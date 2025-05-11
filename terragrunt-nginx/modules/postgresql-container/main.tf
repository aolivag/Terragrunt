# Módulo para crear un contenedor PostgreSQL

resource "docker_image" "postgres" {
  name         = "postgres:15"
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
  
  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}",
    # Pasamos todas las variables de entorno adicionales
    for k, v in var.environment_variables : "${k}=${v}"
  ]
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terragrunt"
  }
  
  # Opciones para persistencia de datos
  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = var.data_path != "" ? var.data_path : "${path.cwd}/postgres-data"
    read_only      = false
  }

  # Opción para cargar scripts SQL iniciales si se proporciona la ruta
  dynamic "volumes" {
    for_each = var.init_scripts_path != "" ? [1] : []
    content {
      container_path = "/docker-entrypoint-initdb.d"
      host_path      = var.init_scripts_path
      read_only      = true
    }
  }
  
  # Healthcheck para PostgreSQL
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.postgres_user} -d ${var.postgres_db}"]
    interval     = "10s"
    timeout      = "5s"
    start_period = "10s"
    retries      = 3
  }
}
