output "container_id" {
  description = "ID of the Vault container"
  value       = docker_container.vault.id
}

output "container_name" {
  description = "Name of the Vault container"
  value       = docker_container.vault.name
}

output "vault_address" {
  description = "Address of the Vault API"
  value       = "http://localhost:${var.external_port}"
}

output "vault_token" {
  description = "Root token for Vault access"
  value       = var.vault_token
  sensitive   = true
}
