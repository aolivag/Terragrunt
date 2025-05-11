# Ejecuta comandos Terragrunt para PostgreSQL en entornos específicos
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "prod", "all")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "plan",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkingDirectory = "$PSScriptRoot"
)

$ErrorActionPreference = "Stop"

function Execute-Terragrunt {
    param (
        [string]$Env,
        [string]$Action
    )
    
    Write-Host "========================================================="
    Write-Host "Ejecutando PostgreSQL para entorno: $Env" -ForegroundColor Cyan
    Write-Host "Acción: $Action" -ForegroundColor Cyan
    Write-Host "========================================================="
    
    $EnvPath = Join-Path -Path "$WorkingDirectory\terragrunt-nginx\environments\$Env" -ChildPath "postgresql"
    
    # Verificar que el directorio existe
    if (-not (Test-Path $EnvPath)) {
        Write-Host "¡Error! No se encontró el directorio $EnvPath" -ForegroundColor Red
        exit 1
    }
    
    # Cambiar al directorio de trabajo
    Push-Location $EnvPath
    
    try {
        # Verificar que Terragrunt está disponible
        $TerragruntPath = "$WorkingDirectory\bin\terragrunt.exe"
        if (-not (Test-Path $TerragruntPath)) {
            Write-Host "¡Error! No se encontró terragrunt.exe en $TerragruntPath" -ForegroundColor Red
            exit 1
        }
        
        # Ejecutar comando terragrunt
        if ($Action -eq "plan") {
            Write-Host "Ejecutando terragrunt plan..." -ForegroundColor Yellow
            & $TerragruntPath plan
            if ($LASTEXITCODE -ne 0) {
                throw "Error al ejecutar terragrunt plan"
            }
        }
        elseif ($Action -eq "apply") {
            Write-Host "Ejecutando terragrunt apply..." -ForegroundColor Yellow
            & $TerragruntPath apply -auto-approve
            if ($LASTEXITCODE -ne 0) {
                throw "Error al ejecutar terragrunt apply"
            }
            
            # Mostrar información de conexión después de aplicar
            Write-Host "========================================================="
            Write-Host "PostgreSQL desplegado exitosamente en entorno: $Env" -ForegroundColor Green
            Write-Host "Información de conexión:"
            Write-Host "  - Host: localhost"
            Write-Host "  - Puerto: $(if ($Env -eq "dev") { "5432" } else { "5433" })"
            Write-Host "  - Base de datos: $(if ($Env -eq "dev") { "dev_database" } else { "prod_database" })"
            Write-Host "  - Usuario: $(if ($Env -eq "dev") { "dev_user" } else { "prod_user" })"
            
            # Verificar que el contenedor está funcionando
            Start-Sleep -Seconds 5
            Write-Host "Verificando estado del contenedor PostgreSQL..."
            docker ps | Select-String "postgres-$Env"
        }
        elseif ($Action -eq "destroy") {
            Write-Host "¿Estás seguro de que deseas destruir la infraestructura en $Env?" -ForegroundColor Red
            Write-Host "Escribe 'SI' para confirmar:" -ForegroundColor Red
            $confirmation = Read-Host
            
            if ($confirmation -eq "SI") {
                Write-Host "Ejecutando terragrunt destroy..." -ForegroundColor Yellow
                & $TerragruntPath destroy -auto-approve
                if ($LASTEXITCODE -ne 0) {
                    throw "Error al ejecutar terragrunt destroy"
                }
            }
            else {
                Write-Host "Operación cancelada" -ForegroundColor Yellow
            }
        }
    }
    finally {
        # Volver al directorio original
        Pop-Location
    }
}

# Procesar entornos
if ($Environment -eq "all") {
    Execute-Terragrunt -Env "dev" -Action $Action
    Execute-Terragrunt -Env "prod" -Action $Action
}
else {
    Execute-Terragrunt -Env $Environment -Action $Action
}
