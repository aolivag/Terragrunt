include {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules//postgres-container"
}

inputs = {
  container_name = "postgres-dev"
  external_port  = 5432
  environment_variables = {
    "POSTGRES_PASSWORD" = "postgres" # Warning: Use a secure password in production
    "POSTGRES_USER"     = "postgres"
    "POSTGRES_DB"       = "app_database"
    "PGDATA"            = "/var/lib/postgresql/data/pgdata"
  }
  postgres_version  = "15"
  postgres_user     = "postgres"
  postgres_password = "postgres" # Warning: Use a secure password in production
  postgres_db       = "app_database"
    # Path for data persistence
  data_path = "${get_terragrunt_dir()}/data"
}
