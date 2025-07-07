# =============================================================================
# SCRIPT RÁPIDO - TEST Y PUSH (PowerShell)
# =============================================================================
# Versión simplificada para uso diario
# =============================================================================

param(
    [switch]$Auto,
    [string]$Message = ""
)

Write-Host "🚀 Ejecutando pipeline rápido..." -ForegroundColor Yellow

# Verificar si estamos en un repositorio Git
try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
}
catch {
    Write-Host "❌ No estás en un repositorio Git" -ForegroundColor Red
    exit 1
}

# Verificar si hay cambios
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "ℹ️  No hay cambios para procesar" -ForegroundColor Yellow
    exit 0
}

# Ejecutar pruebas
Write-Host "🧪 Ejecutando pruebas..." -ForegroundColor Yellow
npm run test:ci

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Las pruebas fallaron. Abortando push." -ForegroundColor Red
    exit 1
}

# Ejecutar linting si existe
if (Get-Command eslint -ErrorAction SilentlyContinue) {
    Write-Host "🔍 Ejecutando linting..." -ForegroundColor Yellow
    npm run lint:fix
}

# Agregar cambios y hacer commit
Write-Host "📝 Haciendo commit..." -ForegroundColor Yellow
git add .

# Mensaje de commit con timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "feat: automated update - $timestamp"

# Usar mensaje personalizado si se proporcionó
if (![string]::IsNullOrEmpty($Message)) {
    $commitMessage = $Message
}
elseif (!$Auto) {
    Write-Host "Mensaje por defecto: $commitMessage" -ForegroundColor Yellow
    $customMessage = Read-Host "Mensaje personalizado (Enter para usar el por defecto)"
    if (![string]::IsNullOrEmpty($customMessage)) {
        $commitMessage = $customMessage
    }
}

git commit -m $commitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al hacer commit" -ForegroundColor Red
    exit 1
}

# Hacer push
Write-Host "🚀 Haciendo push..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ ¡Pipeline completado exitosamente!" -ForegroundColor Green
    Write-Host "🌐 Revisa el progreso en GitHub Actions" -ForegroundColor Green
}
else {
    Write-Host "❌ Error al hacer push" -ForegroundColor Red
    exit 1
}
