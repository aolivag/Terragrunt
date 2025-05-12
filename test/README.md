# Terratest for Terragrunt-Nginx

This directory contains Terratest tests for the Terragrunt-managed infrastructure.

## Requirements

- Go 1.16 or later
- Terragrunt installed and in PATH
- Docker running (for local testing)

## Test Structure

- `nginx_test.go`: Tests for the dev environment Nginx and Postgres deployments
- `nginx_prod_test.go`: Tests for the production environment (requires valid domain)
- `test_helpers.go`: Helper functions for tests

## Running Tests

### Run all tests
```bash
go test -v ./...
```

### Run only dev environment tests (skip production tests)
```bash
go test -v -short ./...
```

### Run a specific test
```bash
go test -v -run TestNginxDeploymentDev
```

## Test Architecture

The tests use Terragrunt to:
1. Deploy infrastructure using `terragrunt apply`
2. Validate the outputs
3. Test the functionality (HTTP endpoints, database connectivity)
4. Clean up resources using `terragrunt destroy`

## CI/CD Integration

You can integrate these tests into your CI/CD pipeline by adding the following step:

```yaml
- name: Run Terratest
  run: |
    cd test
    go test -v -short ./...  # Skip production tests in CI
```

# Run development tests only
.\run-terratest.ps1

# Run all tests including production
.\run-terratest.ps1 --prod

# Run a specific test
.\run-terratest.ps1 --test=TestNginxDeploymentDev