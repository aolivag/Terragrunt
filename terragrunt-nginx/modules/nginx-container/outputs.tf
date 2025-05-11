output "container_id" {
  description = "ID del contenedor nginx"
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "Nombre del contenedor nginx"
  value       = docker_container.nginx.name
}

output "ip_address" {
  description = "Dirección IP del contenedor nginx"
  value       = "localhost:${var.external_port}"
}
