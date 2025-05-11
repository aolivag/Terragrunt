include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//nginx-container"
}

inputs = {
  container_name = "nginx-dev"
  external_port  = 8081
  environment_variables = {
    "NGINX_HOST" = "localhost"
    "NGINX_PORT" = "8081"
  }
  content_path = "${get_terragrunt_dir()}/html"
}
