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

variable "postgres_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "postgres"
}

variable "environment_variables" {
  description = "Additional environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "data_path" {
  description = "Host path for PostgreSQL data persistence"
  type        = string
  default     = ""
}

variable "init_scripts_path" {
  description = "Host path for initialization SQL scripts"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}
