# Terragrunt Nginx Project

This project demonstrates how to use Terragrunt to deploy Nginx containers using Docker on Windows, with a structured project layout for multiple environments.

## Project Structure

```
terragrunt-nginx/
├── terragrunt.hcl                 # Root Terragrunt configuration
├── run-terragrunt.ps1             # PowerShell script for local execution
├── environments/                  # Environment-specific configurations
│   ├── dev/
│   │   ├── terragrunt.hcl         # Dev environment configuration
│   │   └── html/                  # Custom HTML content for dev
│   │       └── index.html
│   └── prod/
│       ├── terragrunt.hcl         # Production environment configuration
│       └── html/                  # Custom HTML content for prod
│           └── index.html
└── modules/                       # Reusable Terraform modules
    └── nginx-container/           # Module for deploying Nginx containers
        ├── main.tf                # Main Terraform configuration
        ├── variables.tf           # Input variables
        └── outputs.tf             # Output values
```

## Requirements

- Terraform v1.6.0+
- Terragrunt v0.62.0+
- Docker Desktop for Windows

## Environment Configuration

The project supports multiple environments:

- **Development (dev)**: Accessible on port 8081
- **Production (prod)**: Accessible on port 8082

Each environment has its own:
- Custom HTML content
- Environment-specific variables
- Independent state management

## Usage

### Method 1: Using PowerShell Script

You can use the included PowerShell script to run Terragrunt commands:

```powershell
# Planning changes for dev environment
.\run-terragrunt.ps1 -Command plan -Environment dev

# Applying changes to prod environment with auto-approval
.\run-terragrunt.ps1 -Command apply -Environment prod -AutoApprove

# Destroying all environments with auto-approval
.\run-terragrunt.ps1 -Command destroy -Environment all -AutoApprove
```

### Method 2: Direct Terragrunt Execution

Navigate to the desired environment directory and run Terragrunt commands:

```powershell
# Navigate to environment directory
cd environments/dev

# Run Terragrunt commands
terragrunt init
terragrunt plan
terragrunt apply
terragrunt destroy
```

### Method 3: Jenkins Pipeline

This project includes a Jenkinsfile in the root directory that allows you to run Terragrunt commands through a Jenkins pipeline. The pipeline supports:

- Running commands on specific environments or all environments
- Planning, applying, and destroying infrastructure
- Confirming destructive operations

See the main README.md file for more details on setting up and using the Jenkins pipeline.

## Customizing Content

To customize the Nginx content:

1. Modify the HTML files in the `environments/[env]/html/` directories
2. Run `terragrunt apply` to update the containers

## Module Configuration

The Nginx container module accepts the following parameters:

- `container_name`: Name of the Docker container
- `external_port`: Port to expose on the host
- `environment_variables`: Environment variables for the container
- `content_path`: Path to the HTML content to mount
