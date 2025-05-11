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
    "POSTGRES_PASSWORD" = "Prod_PostgresPassword123!"  // More secure password for production
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
  postgres_password = "Prod_PostgresPassword123!"  // Same secure password 
  postgres_db       = "app_database_prod"
  
  // Path for data persistence
  data_path = "${get_terragrunt_dir()}/data"
  
  // Set environment to prod
  environment = "prod"
}
