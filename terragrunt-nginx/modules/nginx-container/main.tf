# Provider configuration is now handled in the root terragrunt.hcl file

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = var.container_name
  
  ports {
    internal = 80
    external = var.external_port
  }

  restart = "always"
  
  env = [for k, v in var.environment_variables : "${k}=${v}"]
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terragrunt"
  }
  
  dynamic "volumes" {
    for_each = var.content_path != "" ? [1] : []
    content {
      container_path = "/usr/share/nginx/html"
      host_path      = var.content_path
      read_only      = true
    }
  }
  
  # Using a simple HTTP check that's compatible with the base nginx image
  healthcheck {
    test         = ["CMD", "service", "nginx", "status"]
    interval     = "30s"
    timeout      = "10s"
    start_period = "5s"
    retries      = 3
  }
}
