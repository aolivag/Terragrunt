variable "container_name" {
  description = "Name of the Vault container"
  type        = string
  default     = "vault-container"
}

variable "external_port" {
  description = "External port for the Vault container"
  type        = number
  default     = 8200
}

variable "data_path" {
  description = "Host path for Vault data persistence"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "vault_version" {
  description = "Vault version to use"
  type        = string
  default     = "latest"
}

variable "vault_token" {
  description = "Root token for Vault development mode"
  type        = string
  default     = "root-token"
  sensitive   = true
}
