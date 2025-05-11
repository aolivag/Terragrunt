include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//postgresql-container"
}

inputs = {
  container_name   = "postgres-prod"
  external_port    = 5433  # Puerto diferente para no colisionar con dev
  postgres_user    = "prod_user"
  postgres_password = "secure_prod_password"  # En producción real, usar variables de entorno o un gestor de secretos
  postgres_db      = "prod_database"
  environment_variables = {
    "POSTGRES_HOST_AUTH_METHOD" = "md5"
    "PGDATA" = "/var/lib/postgresql/data/pgdata"
    "ENVIRONMENT" = "production"
  }
  data_path        = "${get_terragrunt_dir()}/postgres-data"  # Esto creará una carpeta para datos persistentes
  init_scripts_path = "${get_terragrunt_dir()}/init-scripts"  # Ruta para los scripts de inicialización
  environment      = "prod"
}
