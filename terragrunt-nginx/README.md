# Terragrunt Nginx Project

This project demonstrates how to use Terragrunt to deploy Nginx containers using Docker on Windows, with a structured project layout for multiple environments.

## Project Structure

```
terragrunt-nginx/
├── terragrunt.hcl                 # Root Terragrunt configuration
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

### Initialize and Deploy

1. Navigate to the desired environment directory:
   ```
   cd environments/dev
   ```

2. Initialize Terragrunt:
   ```
   terragrunt init
   ```

3. Plan the deployment:
   ```
   terragrunt plan
   ```

4. Apply the configuration:
   ```
   terragrunt apply
   ```

### Destroy Resources

To remove the deployed resources:
```
terragrunt destroy
```

## Customization

### Adding a New Environment

1. Create a new directory under `environments/`
2. Copy and modify an existing environment's `terragrunt.hcl`
3. Create a custom `html` directory with your content
4. Deploy using the steps above

### Modifying the Nginx Configuration

Update the module in `modules/nginx-container` to customize the Nginx configuration.

## Output Variables

After deployment, Terragrunt outputs:
- `container_id`: The ID of the deployed container
- `container_name`: The name of the container
- `ip_address`: The address where the Nginx server is accessible

## Docker Healthcheck

The containers include a health check that verifies Nginx is running correctly.
