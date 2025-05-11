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
            }
        }
        
        stage('Validate Tools') {
            steps {                powershell '''
                    # Check if Terragrunt is available
                    if (-Not (Test-Path -Path "${env:WORKSPACE}\\bin\\terragrunt.exe")) {
                        Write-Error "Terragrunt executable not found at ${env:WORKSPACE}\\bin\\terragrunt.exe"
                        exit 1
                    }
                    
                    # Display versions
                    Write-Host "Terragrunt version:"
                    & "${env:WORKSPACE}\\bin\\terragrunt.exe" --version
                    
                    # Check Docker connectivity
                    Write-Host "Checking Docker connectivity:"
                    docker version
                    if ($LASTEXITCODE -ne 0) {
                        Write-Error "Docker not available or not running"
                        exit 1
                    }
                '''
            }
        }
        
        stage('Terragrunt Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {                powershell '''
                    cd "${env:WORKSPACE}\\terragrunt-nginx"
                    
                    Write-Host "Running Terragrunt Plan for environment: ${env:ENVIRONMENT}"
                    & .\\run-terragrunt.ps1 -Command "plan" -Environment "${env:ENVIRONMENT}"
                    
                    if ($LASTEXITCODE -ne 0) {
                        Write-Error "Terragrunt plan failed"
                        exit 1
                    }
                '''
            }
        }
        
        stage('Terragrunt Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {                powershell '''
                    cd "${env:WORKSPACE}\\terragrunt-nginx"
                    Write-Host "Running Terragrunt Apply for environment: ${env:ENVIRONMENT}"
                    & .\\run-terragrunt.ps1 -Command "apply" -Environment "${env:ENVIRONMENT}" -AutoApprove
                    
                    if ($LASTEXITCODE -ne 0) {
                        Write-Error "Terragrunt apply failed"
                        exit 1
                    }
                '''
            }
        }
        
        stage('Terragrunt Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: "Are you sure you want to destroy the ${params.ENVIRONMENT} environment?", ok: 'Destroy'
                  powershell '''
                    cd "${env:WORKSPACE}\\terragrunt-nginx"
                    Write-Host "Running Terragrunt Destroy for environment: ${env:ENVIRONMENT}"
                    & .\\run-terragrunt.ps1 -Command "destroy" -Environment "${env:ENVIRONMENT}" -AutoApprove
                    
                    if ($LASTEXITCODE -ne 0) {
                        Write-Error "Terragrunt destroy failed"
                        exit 1
                    }
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
