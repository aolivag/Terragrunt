variable "container_name" {
  description = "Name of the PostgreSQL container"
  type        = string
  default     = "postgres-container"
}

variable "external_port" {
  description = "External port for the PostgreSQL container"
  type        = number
  default     = 5432
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "data_path" {
  description = "Host path for PostgreSQL data persistence"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "postgres_version" {
  description = "PostgreSQL version to use"
  type        = string
  default     = "15"
}

variable "postgres_user" {
  description = "PostgreSQL default user"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL default user password"
  type        = string
  sensitive   = true
  default     = null  # When null, will attempt to fetch from Vault
}

variable "use_vault" {
  description = "Whether to use Vault for secrets"
  type        = bool
  default     = false
}

variable "vault_address" {
  description = "Vault server address"
  type        = string
  default     = "http://vault-secrets:8200"
}

variable "vault_token" {
  description = "Vault token for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_secret_path" {
  description = "Path in Vault where the PostgreSQL password is stored"
  type        = string
  default     = ""
}

variable "postgres_db" {
  description = "PostgreSQL default database name"
  type        = string
  default     = "postgres"
}
