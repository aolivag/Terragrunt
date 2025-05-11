# Integración de SonarQube con Jenkins para el Proyecto Terragrunt

Este documento describe cómo configurar y utilizar la integración de SonarQube con Jenkins para el análisis de calidad de código del proyecto Terragrunt.

## Requisitos Previos

1. Jenkins instalado y configurado
2. SonarQube Server instalado y en ejecución (por defecto en http://localhost:9000)
3. Plugin de SonarQube Scanner para Jenkins instalado

## Configuración en Jenkins

### 1. Instalar los Plugins Necesarios

1. Navega a **Administrar Jenkins > Administrar Plugins**
2. En la pestaña **Disponibles**, busca e instala los siguientes plugins:
   - SonarQube Scanner
   - Pipeline Utility Steps

### 2. Configurar SonarQube Server en Jenkins

1. Navega a **Administrar Jenkins > Configuración del Sistema**
2. Busca la sección **SonarQube servers**
3. Haz clic en **Add SonarQube**
4. Configura los siguientes campos:
   - Name: `SonarServer` (este nombre debe coincidir con el usado en el Jenkinsfile)
   - Server URL: `http://localhost:9000` (o la URL donde está accesible tu servidor SonarQube)
   - Server authentication token: Genera un token en SonarQube y añádelo aquí
5. Guarda la configuración

## Métodos para ejecutar SonarQube Scanner

El Jenkinsfile está configurado para usar el método de descarga directa del SonarQube Scanner, que no requiere configuración adicional. Sin embargo, a continuación se explican dos métodos alternativos:

### Método 1: Descarga Directa (Actual)

- **Ventajas**: No requiere configuración adicional en Jenkins
- **Desventajas**: Descarga el scanner en cada ejecución, lo que puede ralentizar el proceso
- **Configuración**: Ya está implementado en el Jenkinsfile actual

### Método 2: Usar Maven (requiere configuración adicional)

1. Navega a **Administrar Jenkins > Global Tool Configuration**
2. Busca la sección **Maven**
3. Haz clic en **Add Maven**
4. Configura los siguientes campos:
   - Name: `Maven` (este nombre debe coincidir con el usado en el Jenkinsfile)
   - Selecciona la opción **Install automatically** o especifica la ruta a tu instalación de Maven
5. Guarda la configuración
6. Modifica el Jenkinsfile para usar Maven:
   - Descomenta la sección `tools { maven 'Maven' }`
   - Cambia el comando de análisis por el enfoque de Maven:
   ```groovy
   bat """
       echo "Executing SonarQube Scanner via Maven"
       mvn sonar:sonar ^
       -Dsonar.projectKey=Terragrunt ^
       -Dsonar.projectName="Terragrunt Nginx Project" ^
       -Dsonar.projectVersion=1.0.%BUILD_NUMBER% ^
       -Dsonar.sources=. ^
       -Dsonar.exclusions=**/.terragrunt-cache/**,**/bin/**,**/.terraform/** ^
       -Dsonar.java.binaries=.
   """
   ```

### Método 3: Instalar SonarQube Scanner como herramienta global

1. Navega a **Administrar Jenkins > Global Tool Configuration**
2. Busca la sección **SonarQube Scanner**
3. Haz clic en **Add SonarQube Scanner**
4. Configura los siguientes campos:
   - Name: `SonarScanner` 
   - Selecciona la opción **Install automatically**
5. Guarda la configuración
6. Modifica el Jenkinsfile para usar la herramienta global:
   ```groovy
   tools {
       sonar 'SonarScanner'
   }
   ```
   Y cambia el comando por:
   ```groovy
   bat """
       echo "Executing SonarQube Scanner"
       sonar-scanner ^
       -Dsonar.projectKey=Terragrunt ^
       -Dsonar.projectName="Terragrunt Nginx Project" ^
       -Dsonar.projectVersion=1.0.%BUILD_NUMBER% ^
       -Dsonar.sources=. ^
       -Dsonar.exclusions=**/.terragrunt-cache/**,**/bin/**,**/.terraform/**
   """
   ```

## Configuración en SonarQube

1. Inicia sesión en la interfaz web de SonarQube (por defecto http://localhost:9000)
2. Crea un nuevo proyecto con la clave `Terragrunt`
3. Genera un token de autenticación en **Mi Cuenta > Seguridad > Tokens**

## Uso del Pipeline

El pipeline de Jenkins está configurado para ejecutar automáticamente un análisis de SonarQube cuando se selecciona el parámetro `RUN_SONAR`. Los pasos que realiza son:

1. Checkout del código fuente
2. Ejecución del análisis de SonarQube
3. Espera a que se complete el análisis
4. Verificación del Quality Gate

## Personalización del Análisis

El análisis de SonarQube se puede personalizar modificando las propiedades en el Jenkinsfile:

```
-Dsonar.projectKey=Terragrunt
-Dsonar.projectName="Terragrunt Nginx Project"
-Dsonar.projectVersion=1.0.%BUILD_NUMBER%
-Dsonar.sources=.
-Dsonar.exclusions=**/.terragrunt-cache/**,**/bin/**,**/.terraform/**
```

Algunas propiedades comunes para personalizar:

- `sonar.sources`: Directorio con el código fuente a analizar
- `sonar.exclusions`: Patrones para excluir archivos del análisis
- `sonar.tests`: Directorio con los tests
- `sonar.coverage.exclusions`: Archivos a excluir de las métricas de cobertura
- `sonar.qualitygate.wait`: Si se debe esperar por el quality gate (true/false)

## Resolución de Problemas

### Error: No se puede conectar a SonarQube

1. Verifica que el servidor SonarQube esté en ejecución
2. Comprueba que la URL configurada en Jenkins sea correcta
3. Asegúrate de que el token de autenticación sea válido

### Error: La descarga del SonarQube Scanner falla

1. Verifica la conectividad desde Jenkins al servidor SonarQube
2. Comprueba si hay algún proxy o firewall bloqueando las descargas
3. Considera usar el método 3 (instalación global del SonarQube Scanner)

### Error: Timeout esperando por el Quality Gate

1. Verifica los logs en SonarQube para ver si hay errores en el análisis
2. Aumenta el timeout en el Jenkinsfile si el análisis tarda más de 5 minutos
3. Considera establecer `abortPipeline: false` temporalmente para diagnóstico

## Referencias Adicionales

- [Documentación de SonarQube](https://docs.sonarqube.org/)
- [Documentación del plugin SonarQube Scanner para Jenkins](https://docs.sonarqube.org/latest/analysis/jenkins/)
- [Propiedades de análisis de SonarQube](https://docs.sonarqube.org/latest/analysis/analysis-parameters/)
