# Run Terratest for Terragrunt-Nginx
# This script runs the Terratest tests for the Terragrunt-managed infrastructure

$ErrorActionPreference = "Stop"

Write-Host "Starting Terratest for Terragrunt-Nginx..." -ForegroundColor Green

# Check if Go is installed
try {
    $goVersion = (go version)
    Write-Host "Using $goVersion" -ForegroundColor Green
}
catch {
    Write-Host "Go is not installed or not in PATH. Please install Go first." -ForegroundColor Red
    exit 1
}

# Check if Terragrunt is installed
try {
    $tgVersion = (terragrunt --version)
    Write-Host "Using $tgVersion" -ForegroundColor Green
}
catch {
    Write-Host "Terragrunt is not installed or not in PATH. Please install Terragrunt first." -ForegroundColor Red
    exit 1
}

# Change to the test directory
Push-Location -Path "$PSScriptRoot\test"

# Download Go dependencies
Write-Host "Downloading Go dependencies..." -ForegroundColor Yellow
go mod tidy

# Parse arguments
$runProduction = $args -contains "--prod"
$testName = ""

foreach ($arg in $args) {
    if ($arg -match "^--test=(.+)$") {
        $testName = $Matches[1]
    }
}

# Run tests
if ($runProduction) {
    Write-Host "Running all tests including production..." -ForegroundColor Yellow
    if ($testName) {
        & go test -v -run $testName ./...
    } else {
        & go test -v ./...
    }
}
else {
    Write-Host "Running development tests only (use --prod to include production tests)..." -ForegroundColor Yellow
    if ($testName) {
        & go test -v -short -run $testName ./...
    } else {
        & go test -v -short ./...
    }
}

# Return to original directory
Pop-Location

Write-Host "Terratest completed!" -ForegroundColor Green
