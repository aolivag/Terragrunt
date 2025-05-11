# Terragrunt Nginx y PostgreSQL Pipeline

Este proyecto implementa contenedores Nginx y PostgreSQL utilizando Terragrunt y puede ejecutarse en un pipeline de Jenkins en Windows.

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
	run-postgresql.ps1
	terragrunt.hcl
	environments/
		dev/
			terraform.tfstate
			terragrunt.hcl
			html/
				index.html
			postgresql/
				terragrunt.hcl
				init-scripts/
					01-init.sql
		prod/
			terraform.tfstate
			terragrunt.hcl
			html/
				index.html
			postgresql/
				terragrunt.hcl
				init-scripts/
					01-init.sql
	modules/
		nginx-container/
			main.tf
			outputs.tf
			variables.tf
		postgresql-container/
			main.tf
			outputs.tf
			variables.tf
			README.md
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
- **COMPONENT**: El componente a desplegar (`nginx`, `postgresql` o `all`)

El pipeline incluye los siguientes pasos:
1. **Checkout**: Obtiene el código del repositorio
2. **Validate Tools**: Verifica que Terragrunt y Docker estén disponibles
3. **Process Environment**: Ejecuta el comando de Terragrunt seleccionado en el entorno y componente especificados

## Seguridad

El pipeline incluye una confirmación adicional antes de ejecutar el comando `destroy` para evitar eliminaciones accidentales.

## Ejecución Local

Además del pipeline de Jenkins, puedes ejecutar Terragrunt localmente usando los scripts PowerShell incluidos:

### Para Nginx:

```powershell
# Ejemplos de uso para Nginx
.\terragrunt-nginx\run-terragrunt.ps1 -Command plan -Environment dev
.\terragrunt-nginx\run-terragrunt.ps1 -Command apply -Environment prod -AutoApprove
.\terragrunt-nginx\run-terragrunt.ps1 -Command destroy -Environment all -AutoApprove
```

### Para PostgreSQL:

```powershell
# Ejemplos de uso para PostgreSQL
.\terragrunt-nginx\run-postgresql.ps1 -Environment dev -Action plan
.\terragrunt-nginx\run-postgresql.ps1 -Environment prod -Action apply
.\terragrunt-nginx\run-postgresql.ps1 -Environment all -Action destroy
```

## Mantenimiento

Los archivos de estado de Terraform se generan localmente. Para un entorno de producción, considera configurar un backend remoto para almacenar estos archivos de estado de manera compartida y segura.

## Información de Conexión a PostgreSQL

### Entorno de Desarrollo:
- **Host**: localhost
- **Puerto**: 5432
- **Base de datos**: dev_database
- **Usuario**: dev_user
- **Contraseña**: dev_password (cambiar en producción)

### Entorno de Producción:
- **Host**: localhost
- **Puerto**: 5433
- **Base de datos**: prod_database
- **Usuario**: prod_user
- **Contraseña**: secure_prod_password (cambiar en producción)

## Seguridad de PostgreSQL

Para un entorno de producción real, se recomienda:

1. Almacenar las contraseñas en un servicio de gestión de secretos o variables de entorno seguras
2. Configurar reglas de firewall para limitar el acceso a los puertos de PostgreSQL
3. Usar contenedores con volúmenes persistentes gestionados de manera segura
4. Implementar copias de seguridad regulares de las bases de datos
