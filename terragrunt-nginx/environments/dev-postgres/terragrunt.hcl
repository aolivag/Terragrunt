include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//postgres-container"
}

inputs = {
  container_name = "postgres-dev"
  external_port  = 5432
  environment_variables = {
    "POSTGRES_USER"     = "postgres"
    "POSTGRES_DB"       = "app_database"
    "PGDATA"            = "/var/lib/postgresql/data/pgdata"
  }
  postgres_version  = "15"
  postgres_user     = "postgres"
  postgres_db       = "app_database"
  
  # Vault settings for password retrieval
  use_vault         = true
  vault_address     = "http://localhost:8200"
  vault_token       = "VAULT_TERRAGRUNT_SECRET_TOKEN_2025"
  vault_secret_path = "postgres/dev"
  
  # Path for data persistence
  data_path = "${get_terragrunt_dir()}/data"
}
