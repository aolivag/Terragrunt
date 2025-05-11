# Script to run Terragrunt commands across all environments
param (
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove = $false
)

$terragruntPath = "C:\Users\Usuario\Desktop\Terragrunt\bin\terragrunt.exe"
$basePath = "C:\Users\Usuario\Desktop\Terragrunt\terragrunt-nginx\environments"

function Run-TerragruntCommand {
    param (
        [string]$EnvPath,
        [string]$EnvName,
        [string]$Cmd
    )
    
    Write-Host "Running '$Cmd' in $EnvName environment..." -ForegroundColor Cyan
    
    Push-Location $EnvPath
    try {
        # Add -auto-approve flag for apply and destroy commands when AutoApprove is specified
        if ($AutoApprove -and ($Cmd -eq "apply" -or $Cmd -eq "destroy")) {
            Write-Host "Auto approve enabled for $Cmd command" -ForegroundColor Yellow
            & $terragruntPath $Cmd -auto-approve
        } else {
            & $terragruntPath $Cmd
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error running terragrunt $Cmd in $EnvName environment" -ForegroundColor Red
        } else {
            Write-Host "Successfully completed '$Cmd' in $EnvName environment" -ForegroundColor Green
        }
    } finally {
        Pop-Location
    }
}

# List available environments
$environments = Get-ChildItem -Path $basePath -Directory | Select-Object -ExpandProperty Name

if ($Environment -eq "all") {
    foreach ($env in $environments) {
        $envPath = Join-Path $basePath $env
        Run-TerragruntCommand -EnvPath $envPath -EnvName $env -Cmd $Command
    }
} elseif ($environments -contains $Environment) {
    $envPath = Join-Path $basePath $Environment
    Run-TerragruntCommand -EnvPath $envPath -EnvName $Environment -Cmd $Command
} else {
    Write-Host "Environment '$Environment' not found. Available environments: $($environments -join ', ')" -ForegroundColor Red
}
