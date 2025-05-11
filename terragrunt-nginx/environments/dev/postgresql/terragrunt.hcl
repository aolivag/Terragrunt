include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//postgresql-container"
}

inputs = {
  container_name   = "postgres-dev"
  external_port    = 5432
  postgres_user    = "dev_user"
  postgres_password = "dev_password"  # En producción, usar variables de entorno o un gestor de secretos
  postgres_db      = "dev_database"
  environment_variables = {
    "POSTGRES_HOST_AUTH_METHOD" = "md5"
    "PGDATA" = "/var/lib/postgresql/data/pgdata"
  }
  data_path        = "${get_terragrunt_dir()}/postgres-data"  # Esto creará una carpeta para datos persistentes
  init_scripts_path = "${get_terragrunt_dir()}/init-scripts"  # Ruta para los scripts de inicialización
  environment      = "dev"
}
