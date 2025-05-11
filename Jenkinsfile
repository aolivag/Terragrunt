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
        booleanParam(
            name: 'RUN_SONAR',
            defaultValue: true,
            description: 'Run SonarQube analysis'
        )
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    tools {
        // Definir la herramienta SonarQube Scanner
        maven 'Maven'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('SonarQube Analysis') {
            when {
                expression { return params.RUN_SONAR }
            }
            steps {
                echo "Running SonarQube analysis"
                withSonarQubeEnv('SonarServer') {  // 'SonarServer' debe coincidir con el nombre configurado en Jenkins
                    // Usar el scanner que viene con Maven (más fácil que configurar sonar-scanner directamente)
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
                }
                // Esperar a que el análisis se complete y verificar el Quality Gate
                timeout(time: 5, unit: 'MINUTES') {
                    // El Quality Gate debe ser establecido como "abortPipeline: false" para evitar fallos en las primeras ejecuciones
                    waitForQualityGate abortPipeline: false
                }
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
    dir("${WORKSPACE}\\terragrunt-nginx\\environments\\${env}") {
        echo "Current directory: ${pwd()}"
        echo "Running Terragrunt in ${env} environment"
        
        if (params.ACTION == 'plan' || params.ACTION == 'apply') {
            echo "Running Terragrunt plan for ${env}"
            def planResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe plan", returnStatus: true)
            if (planResult != 0) {
                error "Terragrunt plan failed for ${env}"
            }
        }
        
        if (params.ACTION == 'apply') {
            echo "Running Terragrunt apply for ${env}"
            def applyResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe apply -auto-approve", returnStatus: true)
            if (applyResult != 0) {
                error "Terragrunt apply failed for ${env}"
            }
        }
        
        if (params.ACTION == 'destroy') {
            input message: "Are you sure you want to destroy the ${env} environment?", ok: 'Destroy'
            echo "Running Terragrunt destroy for ${env}"
            def destroyResult = bat(script: "${WORKSPACE}\\bin\\terragrunt.exe destroy -auto-approve", returnStatus: true)
            if (destroyResult != 0) {
                error "Terragrunt destroy failed for ${env}"
            }
        }
    }
}
