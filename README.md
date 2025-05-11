# Terragrunt Nginx Pipeline

Este proyecto implementa un contenedor Nginx utilizando Terragrunt y puede ejecutarse en un pipeline de Jenkins en Windows.

## Estructura del Proyecto

```
bin/
	terragrunt.exe
Jenkinsfile
README.md
docs/
    AnsiColor-Plugin-Installation.md
terragrunt-nginx/
	README.md
	run-terragrunt.ps1
	terragrunt.hcl
	environments/
		dev/
			terraform.tfstate
			terragrunt.hcl
			html/
				index.html
		prod/
			terraform.tfstate
			terragrunt.hcl
			html/
				index.html
	modules/
		nginx-container/
			main.tf
			outputs.tf
			variables.tf
```

## Requisitos para Jenkins

Para ejecutar este pipeline, necesitas:

1. Jenkins instalado en un entorno Windows
2. Plugin de Pipeline instalado en Jenkins
3. Docker Desktop instalado y en ejecución
4. Git instalado

## Configuración del Pipeline en Jenkins

1. Crea un nuevo proyecto de tipo "Pipeline" en Jenkins
2. En la sección "Pipeline", selecciona "Pipeline script from SCM"
3. Selecciona "Git" como SCM
4. Introduce la URL de tu repositorio Git
5. Especifica la rama que quieres construir (ej. `*/main`)
6. En "Script Path", escribe `Jenkinsfile`
7. Guarda la configuración

## Ejecución del Pipeline

Al ejecutar el pipeline, podrás seleccionar:

- **ENVIRONMENT**: El entorno a desplegar (`dev`, `prod` o `all`)
- **ACTION**: La acción a realizar (`plan`, `apply`, `destroy`)

El pipeline incluye los siguientes pasos:
1. **Checkout**: Obtiene el código del repositorio
2. **Validate Tools**: Verifica que Terragrunt y Docker estén disponibles
3. **Process Environment**: Ejecuta el comando de Terragrunt seleccionado en el entorno especificado

## Seguridad

El pipeline incluye una confirmación adicional antes de ejecutar el comando `destroy` para evitar eliminaciones accidentales.

## Ejecución Local

Además del pipeline de Jenkins, puedes ejecutar Terragrunt localmente usando el script PowerShell incluido:

```powershell
# Ejemplos de uso
.\terragrunt-nginx\run-terragrunt.ps1 -Command plan -Environment dev
.\terragrunt-nginx\run-terragrunt.ps1 -Command apply -Environment prod -AutoApprove
.\terragrunt-nginx\run-terragrunt.ps1 -Command destroy -Environment all -AutoApprove
```

## Mantenimiento

Los archivos de estado de Terraform se generan localmente. Para un entorno de producción, considera configurar un backend remoto para almacenar estos archivos de estado de manera compartida y segura.
