# Instalación y Configuración de SonarQube Scanner en Jenkins

Este documento proporciona instrucciones detalladas para instalar y configurar SonarQube Scanner como una herramienta global en Jenkins, necesaria para ejecutar análisis de código en nuestro pipeline.

## Prerrequisitos

1. Jenkins instalado y en funcionamiento
2. Permisos de administrador en Jenkins
3. Servidor SonarQube instalado y accesible desde Jenkins

## Pasos para la Instalación

### 1. Instalar el Plugin de SonarQube Scanner

1. Navega a **Administrar Jenkins > Administrar Plugins**
2. Haz clic en la pestaña **Disponibles**
3. En el campo de búsqueda, escribe "SonarQube Scanner"
4. Marca la casilla para "SonarQube Scanner for Jenkins"
5. Haz clic en "Instalar sin reiniciar" o "Descargar ahora e instalar después de reiniciar"
6. Espera a que la instalación se complete

### 2. Configurar SonarQube Scanner como Herramienta Global

1. Navega a **Administrar Jenkins > Global Tool Configuration**
2. Desplázate hacia abajo hasta la sección **SonarQube Scanner**
3. Haz clic en el botón **Add SonarQube Scanner**
4. Configura los siguientes campos:
   - **Name**: `SonarScanner` (¡Este nombre es crucial! Debe coincidir exactamente con el nombre utilizado en el Jenkinsfile)
   - **Install automatically**: Marca esta casilla para que Jenkins descargue e instale automáticamente el scanner
   - **Install from Maven Central**: Selecciona la versión más reciente disponible
5. Haz clic en **Guardar**

### 3. Configurar la Conexión a SonarQube Server

1. Navega a **Administrar Jenkins > Configuración del Sistema**
2. Desplázate hacia abajo hasta la sección **SonarQube servers**
3. Haz clic en **Add SonarQube**
4. Configura los siguientes campos:
   - **Name**: `SonarServer` (¡Este nombre es crucial! Debe coincidir exactamente con el nombre utilizado en el Jenkinsfile)
   - **Server URL**: La URL de tu servidor SonarQube (por ejemplo: `http://localhost:9000`)
   - **Server authentication token**: 
     - Genera un token en SonarQube (Perfil de usuario > Mi cuenta > Seguridad > Tokens)
     - Copia el token generado en este campo
5. Haz clic en **Guardar**

## Verificación de la Instalación

Para verificar que la herramienta SonarQube Scanner está correctamente instalada y configurada:

1. Crea un nuevo Pipeline Job de prueba en Jenkins
2. En la definición del pipeline, usa el siguiente script:

```groovy
pipeline {
    agent any
    
    tools {
        SonarQubeScanner 'SonarScanner'
    }
    
    stages {
        stage('Verify SonarScanner') {
            steps {
                bat 'sonar-scanner.bat -v'
            }
        }
    }
}
```

3. Ejecuta el pipeline. Si está correctamente configurado, deberías ver la versión del SonarQube Scanner en la salida de la consola.

## Solución de Problemas

### Error: Cannot find SonarScanner executable

Si ves este error, verifica que:
1. El nombre de la herramienta en el Jenkinsfile (`SonarScanner`) coincida exactamente con el configurado en Jenkins
2. La opción "Install automatically" esté marcada en la configuración de la herramienta

### Error: No such DSL method 'SonarQubeScanner'

Este error ocurre cuando el plugin de SonarQube Scanner no está instalado correctamente. Solución:
1. Verifica que el plugin "SonarQube Scanner for Jenkins" esté instalado
2. Reinicia Jenkins si acabas de instalar el plugin

### Error: Cannot connect to SonarQube

Si el scanner está instalado pero no puede conectarse a SonarQube:
1. Verifica que la URL del servidor SonarQube sea correcta
2. Comprueba que el servidor SonarQube esté en ejecución
3. Asegúrate de que el token de autenticación sea válido y no haya expirado

## Referencias

- [Documentación oficial del plugin SonarQube Scanner para Jenkins](https://docs.sonarqube.org/latest/analyzing-source-code/scanners/jenkins-extension-sonarqube/)
- [SonarQube Scanner CLI](https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/)
