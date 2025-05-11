# Configuración de PostgreSQL con Terragrunt y Docker

Este módulo permite desplegar contenedores PostgreSQL en diferentes entornos (desarrollo y producción) utilizando Terragrunt y Docker.

## Estructura del Proyecto

```
terragrunt-nginx/
│
├── modules/
│   └── postgresql-container/         # Módulo de Terraform para PostgreSQL
│       ├── main.tf                   # Definición principal del contenedor
│       ├── variables.tf              # Variables de configuración
│       └── outputs.tf                # Outputs del módulo
│
└── environments/
    ├── dev/
    │   └── postgresql/               # PostgreSQL para desarrollo
    │       ├── terragrunt.hcl        # Configuración específica para desarrollo
    │       └── init-scripts/         # Scripts SQL iniciales para desarrollo
    │           └── 01-init.sql
    │
    └── prod/
        └── postgresql/               # PostgreSQL para producción
            ├── terragrunt.hcl        # Configuración específica para producción
            └── init-scripts/         # Scripts SQL iniciales para producción
                └── 01-init.sql
```

## Características Principales

- **Persistencia de datos**: Los datos de PostgreSQL se persisten en directorios locales
- **Scripts de inicialización**: Cada entorno tiene sus propios scripts para inicializar la base de datos
- **Configuraciones por entorno**: Puertos diferentes para cada entorno para evitar colisiones
- **Healthchecks**: Verificación de salud para asegurar que PostgreSQL está funcionando correctamente
- **Credenciales por entorno**: Usuarios y bases de datos específicas para cada entorno

## Puertos Utilizados

- **Desarrollo**: Puerto 5432
- **Producción**: Puerto 5433

## Credenciales Predeterminadas

### Desarrollo:
- **Usuario**: dev_user
- **Contraseña**: dev_password
- **Base de datos**: dev_database

### Producción:
- **Usuario**: prod_user
- **Contraseña**: secure_prod_password (cambiar en un entorno real)
- **Base de datos**: prod_database

## Uso mediante PowerShell

Puedes usar el script `run-postgresql.ps1` para gestionar los despliegues:

```powershell
# Planificar cambios en desarrollo
.\run-postgresql.ps1 -Environment dev -Action plan

# Aplicar cambios en desarrollo
.\run-postgresql.ps1 -Environment dev -Action apply

# Destruir recursos en desarrollo
.\run-postgresql.ps1 -Environment dev -Action destroy

# Trabajar con producción
.\run-postgresql.ps1 -Environment prod -Action plan
```

## Uso mediante Jenkins

El pipeline de Jenkins permite gestionar tanto NGINX como PostgreSQL:

1. Selecciona el entorno: `dev`, `prod`, o `all`
2. Selecciona la acción: `plan`, `apply`, o `destroy`
3. Selecciona el componente: `nginx`, `postgresql`, o `all`

## Conexión a PostgreSQL

### En desarrollo:
```
Host: localhost
Puerto: 5432
Base de datos: dev_database
Usuario: dev_user
Contraseña: dev_password
```

### En producción:
```
Host: localhost
Puerto: 5433
Base de datos: prod_database
Usuario: prod_user
Contraseña: secure_prod_password
```

## Seguridad

**Importante**: En un entorno real, no guardes las contraseñas de base de datos en el código. Utiliza variables de entorno o servicios de gestión de secretos.
