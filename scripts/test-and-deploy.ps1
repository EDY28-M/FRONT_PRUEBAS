# =============================================================================
# SCRIPT DE AUTOMATIZACIÓN - TEST Y DEPLOY (PowerShell)
# =============================================================================
# Este script ejecuta todas las pruebas, hace commit de cambios y push automático
# Solo realiza el push si todas las pruebas pasan exitosamente
# =============================================================================

param(
    [switch]$Auto,
    [string]$Branch = "main",
    [string]$CommitPrefix = "chore: automated test and deploy"
)

# Función para mostrar mensajes con colores
function Write-ColoredMessage {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    switch ($Type) {
        "Info" { Write-Host "[INFO] $Message" -ForegroundColor Blue }
        "Success" { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
        "Warning" { Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
        "Error" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
    }
}

# Función para mostrar el banner
function Show-Banner {
    Write-Host "=============================================" -ForegroundColor Blue
    Write-Host "  🚀 AUTOMATED TEST & DEPLOY PIPELINE" -ForegroundColor Blue
    Write-Host "=============================================" -ForegroundColor Blue
}

# Función para verificar si estamos en un repositorio Git
function Test-GitRepository {
    try {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        return $true
    }
    catch {
        Write-ColoredMessage "No estás en un repositorio Git" "Error"
        return $false
    }
}

# Función para verificar si hay cambios para commitear
function Test-Changes {
    $status = git status --porcelain
    if ([string]::IsNullOrEmpty($status)) {
        Write-ColoredMessage "No hay cambios para commitear" "Warning"
        return $false
    }
    return $true
}

# Función para instalar dependencias si es necesario
function Install-Dependencies {
    Write-ColoredMessage "Verificando dependencias..."
    
    if (!(Test-Path "node_modules")) {
        Write-ColoredMessage "Instalando dependencias..."
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-ColoredMessage "Error al instalar dependencias" "Error"
            return $false
        }
    }
    else {
        Write-ColoredMessage "Dependencias ya instaladas"
    }
    return $true
}

# Función para ejecutar las pruebas
function Invoke-Tests {
    Write-ColoredMessage "Ejecutando pruebas..."
    
    npm run test:ci
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredMessage "✅ Todas las pruebas pasaron exitosamente" "Success"
        return $true
    }
    else {
        Write-ColoredMessage "❌ Las pruebas fallaron" "Error"
        return $false
    }
}

# Función para ejecutar linting
function Invoke-Linting {
    Write-ColoredMessage "Ejecutando linting..."
    
    if (Get-Command eslint -ErrorAction SilentlyContinue) {
        npm run lint
        if ($LASTEXITCODE -ne 0) {
            Write-ColoredMessage "Se encontraron problemas de linting. Intentando auto-fix..." "Warning"
            npm run lint:fix
            if ($LASTEXITCODE -ne 0) {
                Write-ColoredMessage "No se pudieron corregir automáticamente todos los problemas de linting" "Error"
                return $false
            }
        }
    }
    else {
        Write-ColoredMessage "ESLint no está configurado, saltando linting" "Warning"
    }
    
    Write-ColoredMessage "✅ Linting completado" "Success"
    return $true
}

# Función para hacer commit de los cambios
function Invoke-Commit {
    param([bool]$AutoMode)
    
    Write-ColoredMessage "Preparando commit..."
    
    # Mostrar los cambios que se van a commitear
    Write-ColoredMessage "Cambios a commitear:" "Warning"
    git status --porcelain
    
    # Agregar todos los cambios
    git add .
    
    # Crear mensaje de commit con timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = "$CommitPrefix - $timestamp"
    
    # Permitir al usuario personalizar el mensaje
    if (!$AutoMode) {
        Write-ColoredMessage "Mensaje de commit por defecto: $commitMessage" "Warning"
        $customMessage = Read-Host "¿Quieres usar un mensaje personalizado? (Enter para usar el por defecto)"
        if (![string]::IsNullOrEmpty($customMessage)) {
            $commitMessage = $customMessage
        }
    }
    
    # Hacer commit
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredMessage "✅ Commit realizado exitosamente" "Success"
        return $true
    }
    else {
        Write-ColoredMessage "❌ Error al hacer commit" "Error"
        return $false
    }
}

# Función para hacer push
function Invoke-Push {
    Write-ColoredMessage "Haciendo push a la rama $Branch..."
    
    # Verificar si estamos en la rama correcta
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $Branch) {
        Write-ColoredMessage "Estás en la rama '$currentBranch', cambiando a '$Branch'" "Warning"
        git checkout $Branch
        if ($LASTEXITCODE -ne 0) {
            Write-ColoredMessage "No se pudo cambiar a la rama $Branch" "Error"
            return $false
        }
    }
    
    # Hacer push
    git push origin $Branch
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredMessage "✅ Push realizado exitosamente" "Success"
        Write-ColoredMessage "El pipeline CI/CD se ejecutará automáticamente en GitHub Actions"
        return $true
    }
    else {
        Write-ColoredMessage "❌ Error al hacer push" "Error"
        return $false
    }
}

# Función para mostrar el resumen final
function Show-Summary {
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "  ✅ PIPELINE COMPLETADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "• Pruebas ejecutadas: ✅" -ForegroundColor Green
    Write-Host "• Linting ejecutado: ✅" -ForegroundColor Green
    Write-Host "• Cambios commiteados: ✅" -ForegroundColor Green
    Write-Host "• Push realizado: ✅" -ForegroundColor Green
    Write-Host "• CI/CD activado: ✅" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Revisa el progreso en:" -ForegroundColor Green
    Write-Host "   GitHub Actions: https://github.com/tu-usuario/tu-repo/actions" -ForegroundColor Green
    Write-Host "   Cloud Run: https://console.cloud.google.com/run" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
}

# Función para limpiar en caso de error
function Show-ErrorSummary {
    Write-ColoredMessage "Pipeline interrumpido debido a errores" "Error"
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host "  ❌ PIPELINE FALLIDO" -ForegroundColor Red
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host "• Verifica los errores mostrados arriba" -ForegroundColor Red
    Write-Host "• Corrige los problemas y vuelve a ejecutar" -ForegroundColor Red
    Write-Host "• Los cambios NO han sido enviados al repositorio" -ForegroundColor Red
    Write-Host "=============================================" -ForegroundColor Red
}

# Función principal
function main {
    Show-Banner
    
    if ($Auto) {
        Write-ColoredMessage "Modo automático activado"
    }
    
    # Verificar que estamos en un repositorio Git
    if (!(Test-GitRepository)) {
        exit 1
    }
    
    # Verificar si hay cambios
    if (!(Test-Changes)) {
        Write-ColoredMessage "No hay cambios para procesar. Saliendo..."
        exit 0
    }
    
    # Instalar dependencias
    if (!(Install-Dependencies)) {
        Show-ErrorSummary
        exit 1
    }
    
    # Ejecutar linting
    if (!(Invoke-Linting)) {
        Show-ErrorSummary
        exit 1
    }
    
    # Ejecutar pruebas
    if (!(Invoke-Tests)) {
        Show-ErrorSummary
        exit 1
    }
    
    # Hacer commit
    if (!(Invoke-Commit -AutoMode $Auto)) {
        Show-ErrorSummary
        exit 1
    }
    
    # Hacer push
    if (!(Invoke-Push)) {
        Show-ErrorSummary
        exit 1
    }
    
    # Mostrar resumen
    Show-Summary
}

# Manejar interrupciones (Ctrl+C)
try {
    main
}
catch {
    Show-ErrorSummary
    exit 1
}
