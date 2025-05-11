pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'prod', 'all'],
            description: 'Environment to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terragrunt action to perform'
        )
        choice(
            name: 'COMPONENT',
            choices: ['all', 'nginx', 'postgresql'],
            description: 'Component to deploy (NGINX, PostgreSQL or both)'
        )
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validate Tools') {
            steps {
                echo "Checking if Terragrunt is available"
                fileExists("${WORKSPACE}\\bin\\terragrunt.exe")
                echo "Terragrunt found, checking version:"
                bat(script: "${WORKSPACE}\\bin\\terragrunt.exe --version", returnStatus: true)
                
                echo "Checking Docker connectivity"
                bat(script: "docker version", returnStatus: true)
            }
        }
        
        stage('Process Environment') {
            steps {
                script {
                    if (params.ENVIRONMENT == 'all') {
                        echo "Processing all environments"
                        processEnvironment('dev')
                        processEnvironment('prod')
                    } else {
                        echo "Processing environment: ${params.ENVIRONMENT}"
                        processEnvironment(params.ENVIRONMENT)
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline execution failed"
        }
    }
}

def processEnvironment(String env) {
    if (params.COMPONENT == 'all' || params.COMPONENT == 'nginx') {
        processComponent(env, "nginx")
    }
    
    if (params.COMPONENT == 'all' || params.COMPONENT == 'postgresql') {
        processComponent(env, "postgresql")
    }
}

def processComponent(String env, String component) {
    dir("${WORKSPACE}\\terragrunt-nginx\\environments\\${env}\\${component == 'nginx' ? '' : component}") {
        echo "Current directory: ${pwd()}"
        echo "Running Terragrunt for ${component} in ${env} environment"
        
        if (params.ACTION == 'plan' || params.ACTION == 'apply') {
            echo "Running Terragrunt plan for ${component} in ${env}"
            def planResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe plan", returnStatus: true)
            if (planResult != 0) {
                error "Terragrunt plan failed for ${component} in ${env}"
            }
        }
        
        if (params.ACTION == 'apply') {
            echo "Running Terragrunt apply for ${component} in ${env}"
            def applyResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe apply -auto-approve", returnStatus: true)
            if (applyResult != 0) {
                error "Terragrunt apply failed for ${component} in ${env}"
            }
            
            // Verificar estado del contenedor después del despliegue
            if (component == 'postgresql') {
                echo "Verificando conexión a PostgreSQL en ${env}..."
                def checkPgResult = bat(script: "docker exec ${env == 'dev' ? 'postgres-dev' : 'postgres-prod'} pg_isready -U ${env == 'dev' ? 'dev_user' : 'prod_user'}", returnStatus: true)
                if (checkPgResult != 0) {
                    echo "Advertencia: PostgreSQL podría no estar listo aún. Esperando 10 segundos adicionales..."
                    sleep(time: 10, unit: 'SECONDS')
                    checkPgResult = bat(script: "docker exec ${env == 'dev' ? 'postgres-dev' : 'postgres-prod'} pg_isready -U ${env == 'dev' ? 'dev_user' : 'prod_user'}", returnStatus: true)
                    if (checkPgResult != 0) {
                        error "No se pudo conectar a PostgreSQL después de la espera adicional"
                    }
                }
                echo "Conexión a PostgreSQL establecida correctamente"
                
                // Mostrar información de conexión
                echo "PostgreSQL disponible en: localhost:${env == 'dev' ? '5432' : '5433'}"
                echo "Base de datos: ${env == 'dev' ? 'dev_database' : 'prod_database'}"
                echo "Usuario: ${env == 'dev' ? 'dev_user' : 'prod_user'}"
            } else if (component == 'nginx') {
                echo "Nginx disponible en: localhost:${env == 'dev' ? '8081' : '8082'}"
            }
        }
        
        if (params.ACTION == 'destroy') {
            input message: "Are you sure you want to destroy the ${component} in ${env} environment?", ok: 'Destroy'
            echo "Running Terragrunt destroy for ${component} in ${env}"
            def destroyResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe destroy -auto-approve", returnStatus: true)
            if (destroyResult != 0) {
                error "Terragrunt destroy failed for ${component} in ${env}"
            }
        }
    }
}
