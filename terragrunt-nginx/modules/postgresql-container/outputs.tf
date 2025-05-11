output "container_id" {
  description = "ID del contenedor PostgreSQL"
  value       = docker_container.postgres.id
}

output "container_name" {
  description = "Nombre del contenedor PostgreSQL"
  value       = docker_container.postgres.name
}

output "ip_address" {
  description = "Dirección IP y puerto del contenedor PostgreSQL"
  value       = "localhost:${var.external_port}"
}

output "connection_string" {
  description = "Cadena de conexión a PostgreSQL"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@localhost:${var.external_port}/${var.postgres_db}"
  sensitive   = true
}
