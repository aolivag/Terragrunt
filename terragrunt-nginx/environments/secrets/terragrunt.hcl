include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//vault-container"
}

inputs = {
  container_name = "vault-secrets"
  external_port  = 8200
  environment    = "shared"
  
  # Using a strong token for development. In a real environment, use a truly random value
  vault_token    = "VAULT_TERRAGRUNT_SECRET_TOKEN_2025"
  
  # Path for data persistence (uncomment when using Vault in non-dev mode)
  # data_path = "${get_terragrunt_dir()}/data"
}
