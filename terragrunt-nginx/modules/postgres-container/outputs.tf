output "container_id" {
  description = "ID of the PostgreSQL container"
  value       = docker_container.postgres.id
}

output "container_name" {
  description = "Name of the PostgreSQL container"
  value       = docker_container.postgres.name
}

output "ip_address" {
  description = "IP address of the PostgreSQL container"
  value       = "localhost:${var.external_port}"
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@localhost:${var.external_port}/${var.postgres_db}"
  sensitive   = true
}
