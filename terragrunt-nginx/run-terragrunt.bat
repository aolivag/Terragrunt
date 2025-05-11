@echo off
REM Script to run Terragrunt commands across all environments

set TERRAGRUNT_CMD=%1
set ENVIRONMENT=%2

set TERRAGRUNT_PATH=%WORKSPACE%\bin\terragrunt.exe
set BASE_PATH=%WORKSPACE%\terragrunt-nginx\environments

if "%ENVIRONMENT%"=="all" (
    echo Running %TERRAGRUNT_CMD% across all environments...
    
    for /D %%d in ("%BASE_PATH%\*") do (
        echo Processing environment: %%~nd
        
        pushd "%%d"
        echo Running Terragrunt %TERRAGRUNT_CMD% in %%~nd environment...
        
        if "%TERRAGRUNT_CMD%"=="apply" (
            "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD% -auto-approve
        ) else if "%TERRAGRUNT_CMD%"=="destroy" (
            "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD% -auto-approve
        ) else (
            "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD%
        )
        
        if %ERRORLEVEL% neq 0 (
            echo Error running terragrunt %TERRAGRUNT_CMD% in %%~nd environment
            popd
            exit /b 1
        ) else (
            echo Successfully completed %TERRAGRUNT_CMD% in %%~nd environment
        )
        popd
    )
) else (
    echo Running %TERRAGRUNT_CMD% in %ENVIRONMENT% environment...
    
    if not exist "%BASE_PATH%\%ENVIRONMENT%" (
        echo Environment '%ENVIRONMENT%' not found!
        exit /b 1
    )
    
    pushd "%BASE_PATH%\%ENVIRONMENT%"
    
    if "%TERRAGRUNT_CMD%"=="apply" (
        "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD% -auto-approve
    ) else if "%TERRAGRUNT_CMD%"=="destroy" (
        "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD% -auto-approve
    ) else (
        "%TERRAGRUNT_PATH%" %TERRAGRUNT_CMD%
    )
    
    if %ERRORLEVEL% neq 0 (
        echo Error running terragrunt %TERRAGRUNT_CMD% in %ENVIRONMENT% environment
        popd
        exit /b 1
    ) else (
        echo Successfully completed %TERRAGRUNT_CMD% in %ENVIRONMENT% environment
    )
    popd
)

exit /b 0
