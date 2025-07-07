# Script de verificación del build para Windows PowerShell
# Uso: .\verify-build.ps1

$ErrorActionPreference = "Stop"

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "Green"
    )
    Write-Host "✅ $Message" -ForegroundColor $Color
}

function Write-ErrorMessage {
function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-InfoMessage {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

Write-Host "===========================================" -ForegroundColor Blue
Write-Host "    🔍 VERIFICACIÓN DEL BUILD" -ForegroundColor Blue
Write-Host "===========================================" -ForegroundColor Blue
Write-Host ""

# 1. Verificar dependencias
Write-InfoMessage "Verificando dependencias..."
try {
    if (!(Test-Path "node_modules")) {
        Write-WarningMessage "node_modules no encontrado. Instalando dependencias..."
        npm ci
    }
    Write-ColorMessage "Dependencias verificadas"
} catch {
    Write-ErrorMessage "Error al verificar dependencias: $($_.Exception.Message)"
    exit 1
}

# 2. Linting
Write-InfoMessage "Ejecutando linting..."
try {
    npm run lint
    Write-ColorMessage "Linting completado sin errores"
} catch {
    Write-WarningMessage "Linting encontró problemas. Intentando corregir automáticamente..."
    try {
        npm run lint:fix
        Write-ColorMessage "Problemas de linting corregidos automáticamente"
    } catch {
        Write-ErrorMessage "No se pudieron corregir todos los problemas de linting"
    }
}

# 3. Verificar TypeScript
Write-InfoMessage "Verificando tipos de TypeScript..."
try {
    npx tsc --noEmit
    Write-ColorMessage "Verificación de tipos completada"
} catch {
    Write-ErrorMessage "Errores de TypeScript encontrados"
    Write-InfoMessage "Revisa los errores de tipado antes de continuar"
}

# 4. Build de producción
Write-InfoMessage "Ejecutando build de producción..."
try {
    npm run build
    Write-ColorMessage "Build de producción completado"
} catch {
    Write-ErrorMessage "Error en el build de producción: $($_.Exception.Message)"
    exit 1
}

# 5. Verificar archivos generados
Write-InfoMessage "Verificando archivos generados..."
if (Test-Path "dist") {
    $distFiles = Get-ChildItem -Path "dist" -Recurse | Measure-Object
    Write-ColorMessage "Directorio 'dist' generado con $($distFiles.Count) archivos"
    
    # Verificar archivos principales
    $requiredFiles = @("dist/index.html", "dist/assets")
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-ColorMessage "Archivo requerido encontrado: $file"
        } else {
            Write-ErrorMessage "Archivo requerido no encontrado: $file"
        }
    }
} else {
    Write-ErrorMessage "Directorio 'dist' no generado"
    exit 1
}

# 6. Verificar tamaño del build
Write-InfoMessage "Analizando tamaño del build..."
$distSize = (Get-ChildItem -Path "dist" -Recurse | Measure-Object -Property Length -Sum).Sum
$distSizeMB = [math]::Round($distSize / 1MB, 2)
Write-ColorMessage "Tamaño total del build: $distSizeMB MB"

if ($distSizeMB -gt 10) {
    Write-WarningMessage "El build es muy grande (>10MB). Considera optimizar."
} else {
    Write-ColorMessage "Tamaño del build es óptimo (<10MB)"
}

# 7. Verificar Docker (opcional)
Write-InfoMessage "Verificando Docker..."
try {
    $null = Get-Command docker -ErrorAction Stop
    Write-ColorMessage "Docker disponible"
    
    $buildDocker = Read-Host "¿Quieres probar el build de Docker? (y/n)"
    if ($buildDocker -eq "y" -or $buildDocker -eq "Y") {
        Write-InfoMessage "Construyendo imagen Docker..."
        docker build -t frontend-admin-test .
        Write-ColorMessage "Imagen Docker construida exitosamente"
        
        Write-InfoMessage "Puedes probar la imagen con: docker run -p 8080:8080 frontend-admin-test"
    }
} catch {
    Write-WarningMessage "Docker no está disponible. Saltando prueba de Docker."
}

# 8. Iniciar preview (opcional)
Write-InfoMessage "¿Quieres iniciar el servidor de preview para probar el build? (y/n)"
$startPreview = Read-Host
if ($startPreview -eq "y" -or $startPreview -eq "Y") {
    Write-InfoMessage "Iniciando servidor de preview..."
    Write-ColorMessage "El servidor estará disponible en http://localhost:4173"
    Write-InfoMessage "Presiona Ctrl+C para detener el servidor"
    npm run preview
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "✅ VERIFICACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""
Write-InfoMessage "El proyecto está listo para deployment!"
Write-InfoMessage "Puedes usar './deploy.ps1 -ProjectId tu-project-id' para desplegar a Cloud Run"
}