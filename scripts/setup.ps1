# =============================================================================
# SCRIPT DE CONFIGURACIÓN INICIAL (PowerShell)
# =============================================================================
# Configura los scripts de automatización y crea alias
# =============================================================================

Write-Host "🚀 Configurando scripts de automatización..." -ForegroundColor Blue

# Verificar dependencias
Write-Host "🔍 Verificando dependencias..." -ForegroundColor Yellow

# Verificar Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js no está instalado" -ForegroundColor Red
    Write-Host "   Descárgalo desde: https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Verificar npm
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ npm no está instalado" -ForegroundColor Red
    exit 1
}

# Verificar Git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git no está instalado" -ForegroundColor Red
    Write-Host "   Descárgalo desde: https://git-scm.com/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencias verificadas" -ForegroundColor Green

# Verificar política de ejecución
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "⚠️  La política de ejecución está restringida" -ForegroundColor Yellow
    Write-Host "   Ejecuta como administrador: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    
    $changePolicyInput = Read-Host "¿Quieres cambiar la política ahora? (y/n)"
    if ($changePolicyInput -eq "y" -or $changePolicyInput -eq "Y") {
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "✅ Política de ejecución actualizada" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error al cambiar la política. Ejecuta como administrador" -ForegroundColor Red
            exit 1
        }
    }
}

# Crear alias si el usuario quiere
Write-Host ""
$createAlias = Read-Host "¿Quieres crear alias para los scripts? (y/n) - Esto te permitirá usar 'deploy' y 'quickdeploy' desde cualquier lugar"

if ($createAlias -eq "y" -or $createAlias -eq "Y") {
    # Crear perfil si no existe
    if (!(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -Type File -Force | Out-Null
    }
    
    # Agregar alias al perfil
    $aliasContent = @"

# Alias para scripts de automatización
function deploy { .\scripts\test-and-deploy.ps1 @args }
function quickdeploy { .\scripts\quick-deploy.ps1 @args }
"@
    
    Add-Content $PROFILE $aliasContent
    Write-Host "✅ Alias agregados a tu perfil de PowerShell" -ForegroundColor Green
    Write-Host "   Reinicia PowerShell para usar los alias" -ForegroundColor Green
}

# Instalar dependencias del proyecto
Write-Host ""
Write-Host "🔧 Instalando dependencias del proyecto..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencias instaladas correctamente" -ForegroundColor Green
}
else {
    Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
    exit 1
}

# Ejecutar una prueba inicial
Write-Host ""
Write-Host "🧪 Ejecutando pruebas iniciales..." -ForegroundColor Yellow
npm run test:ci

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Pruebas iniciales pasaron" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Algunas pruebas fallaron, revisa el código" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  ✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Scripts disponibles:" -ForegroundColor Green
Write-Host "• .\scripts\test-and-deploy.ps1 (o 'deploy')" -ForegroundColor Green
Write-Host "• .\scripts\quick-deploy.ps1 (o 'quickdeploy')" -ForegroundColor Green
Write-Host ""
Write-Host "Para usar los scripts:" -ForegroundColor Green
Write-Host "1. Haz cambios en tu código" -ForegroundColor Green
Write-Host "2. Ejecuta: .\scripts\quick-deploy.ps1" -ForegroundColor Green
Write-Host "3. ¡Listo! El código se desplegará automáticamente" -ForegroundColor Green
Write-Host ""
Write-Host "Lee scripts\README.md para más información" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
