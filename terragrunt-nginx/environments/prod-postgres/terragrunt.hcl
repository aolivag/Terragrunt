include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//postgres-container"
}

inputs = {
  container_name = "postgres-prod"
  external_port  = 5433  // Using a different port for production to avoid conflicts
  environment_variables = {
    "POSTGRES_USER"     = "postgres"
    "POSTGRES_DB"       = "app_database_prod"
    "PGDATA"            = "/var/lib/postgresql/data/pgdata"
    // Additional production settings
    "MAX_CONNECTIONS"   = "100"
    "SHARED_BUFFERS"    = "256MB"
    "EFFECTIVE_CACHE_SIZE" = "1GB"
    "WORK_MEM"          = "16MB"
    "MAINTENANCE_WORK_MEM" = "128MB"
  }
  postgres_version  = "15"
  postgres_user     = "postgres"
  postgres_db       = "app_database_prod"
  
  // Vault settings for password retrieval
  use_vault         = true
  vault_address     = "http://localhost:8200"
  vault_token       = "VAULT_TERRAGRUNT_SECRET_TOKEN_2025"
  vault_secret_path = "postgres/prod"
  
  // Path for data persistence
  data_path = "${get_terragrunt_dir()}/data"
  
  // Set environment to prod
  environment = "prod"
}
