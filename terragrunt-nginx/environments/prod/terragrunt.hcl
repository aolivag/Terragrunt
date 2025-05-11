include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/nginx-container"
}

inputs = {
  container_name = "nginx-prod"
  external_port  = 8082
  environment_variables = {
    "NGINX_HOST" = "localhost"
    "NGINX_PORT" = "8082"
    "ENVIRONMENT" = "production"
  }
  content_path = "${get_terragrunt_dir()}/html"
}
