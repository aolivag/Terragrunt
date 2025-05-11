locals {
  terraform_version = "1.6.0"
  terraform_binary  = "terraform.exe"  # Windows specific
  
  # Parse the file path to determine the environment
  parsed_path = regex(".*/environments/(?P<env>[^/]+).*", get_original_terragrunt_dir())
  env         = try(local.parsed_path.env, "dev")
}

remote_state {
  backend = "local"
  
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= ${local.terraform_version}"
    required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.15.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"  # For Windows Docker Desktop
}

# Vault provider is configured in each module that needs it, 
# since it depends on the vault container being available
EOF
}

terraform {
  # Force the use of the Windows Terraform binary
  extra_arguments "windows_binary" {
    commands = [
      "init",
      "plan",
      "apply",
      "destroy"
    ]
    env_vars = {
      TF_CLI_ARGS = "-no-color"
    }
  }
  
  # Add common variables to all commands
  extra_arguments "common_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]
    
    arguments = [
      "-var", "environment=${local.env}"
    ]
  }
}
