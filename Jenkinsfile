pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',            choices: ['dev', 'prod', 'all'],
            description: 'Environment to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terragrunt action to perform'
        )
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        // Nota: Si deseas usar colores ANSI, necesitas instalar el plugin "AnsiColor" en Jenkins
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }        }
          stage('Validate Tools') {
            steps {
                bat '''
                    @echo off
                    echo Checking if Terragrunt is available...
                    if not exist "%WORKSPACE%\\bin\\terragrunt.exe" (
                        echo Terragrunt executable not found at %WORKSPACE%\\bin\\terragrunt.exe
                        exit /b 1
                    )
                    
                    echo Terragrunt version:
                    "%WORKSPACE%\\bin\\terragrunt.exe" --version
                    
                    echo Checking Docker connectivity:
                    docker version
                    if %ERRORLEVEL% neq 0 (
                        echo Docker not available or not running
                        exit /b 1
                    )
                '''
            }        }
          stage('Terragrunt Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                bat '''
                    @echo off
                    cd "%WORKSPACE%\\terragrunt-nginx"
                    
                    echo Running Terragrunt Plan for environment: %ENVIRONMENT%
                    powershell -Command ".\\run-terragrunt.ps1 -Command 'plan' -Environment '%ENVIRONMENT%'"
                    
                    if %ERRORLEVEL% neq 0 (
                        echo Terragrunt plan failed
                        exit /b 1
                    )
                '''
            }        }
          stage('Terragrunt Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                bat '''
                    @echo off
                    cd "%WORKSPACE%\\terragrunt-nginx"
                    echo Running Terragrunt Apply for environment: %ENVIRONMENT%
                    powershell -Command ".\\run-terragrunt.ps1 -Command 'apply' -Environment '%ENVIRONMENT%' -AutoApprove"
                    
                    if %ERRORLEVEL% neq 0 (
                        echo Terragrunt apply failed
                        exit /b 1
                    )
                '''
            }        }
          stage('Terragrunt Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: "Are you sure you want to destroy the ${params.ENVIRONMENT} environment?", ok: 'Destroy'
                bat '''
                    @echo off
                    cd "%WORKSPACE%\\terragrunt-nginx"
                    echo Running Terragrunt Destroy for environment: %ENVIRONMENT%
                    powershell -Command ".\\run-terragrunt.ps1 -Command 'destroy' -Environment '%ENVIRONMENT%' -AutoApprove"
                    
                    if %ERRORLEVEL% neq 0 (
                        echo Terragrunt destroy failed
                        exit /b 1
                    )
                '''
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
