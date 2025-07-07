# Script para configurar Google Cloud para CI/CD
# Uso: .\setup-gcp-cicd.ps1 -ProjectId "tu-project-id"

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceAccountName = "github-actions"
)

Write-Host "☁️  Configurando Google Cloud para CI/CD..." -ForegroundColor Cyan
Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "   Project ID: $ProjectId" -ForegroundColor White
Write-Host "   Service Account: $ServiceAccountName" -ForegroundColor White

# Verificar que gcloud está instalado
try {
    gcloud version | Out-Null
    Write-Host "✅ gcloud CLI encontrado" -ForegroundColor Green
}
catch {
    Write-Host "❌ gcloud CLI no encontrado. Instala Google Cloud SDK primero." -ForegroundColor Red
    Write-Host "   Descarga desde: https://cloud.google.com/sdk" -ForegroundColor Yellow
    exit 1
}

# Configurar proyecto
Write-Host "`n🔧 Configurando proyecto..." -ForegroundColor Yellow
gcloud config set project $ProjectId

# Verificar que el proyecto existe
try {
    $project = gcloud projects describe $ProjectId --format="value(projectId)" 2>$null
    if ($project -eq $ProjectId) {
        Write-Host "✅ Proyecto verificado: $ProjectId" -ForegroundColor Green
    } else {
        throw "Proyecto no encontrado"
    }
}
catch {
    Write-Host "❌ Proyecto '$ProjectId' no encontrado o no tienes acceso" -ForegroundColor Red
    Write-Host "   Verifica el Project ID o crea el proyecto primero" -ForegroundColor Yellow
    exit 1
}

# Habilitar APIs necesarias
Write-Host "`n🔌 Habilitando APIs necesarias..." -ForegroundColor Yellow
$apis = @(
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com"
)

foreach ($api in $apis) {
    Write-Host "   Habilitando $api..." -ForegroundColor Gray
    gcloud services enable $api
}
Write-Host "✅ APIs habilitadas" -ForegroundColor Green

# Crear service account
Write-Host "`n👤 Creando service account..." -ForegroundColor Yellow
$serviceAccountEmail = "$ServiceAccountName@$ProjectId.iam.gserviceaccount.com"

# Verificar si ya existe
$existingAccount = gcloud iam service-accounts list --filter="email:$serviceAccountEmail" --format="value(email)" 2>$null
if ($existingAccount) {
    Write-Host "⚠️  Service account ya existe: $serviceAccountEmail" -ForegroundColor Yellow
} else {
    gcloud iam service-accounts create $ServiceAccountName --display-name="GitHub Actions Deploy"
    Write-Host "✅ Service account creada: $serviceAccountEmail" -ForegroundColor Green
}

# Asignar roles necesarios
Write-Host "`n🔐 Asignando permisos..." -ForegroundColor Yellow
$roles = @(
    "roles/cloudbuild.builds.builder",
    "roles/run.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser"
)

foreach ($role in $roles) {
    Write-Host "   Asignando $role..." -ForegroundColor Gray
    gcloud projects add-iam-policy-binding $ProjectId --member="serviceAccount:$serviceAccountEmail" --role="$role" >$null
}
Write-Host "✅ Permisos asignados" -ForegroundColor Green

# Crear clave JSON
Write-Host "`n🔑 Creando clave de acceso..." -ForegroundColor Yellow
$keyFile = "sa-key-$ProjectId.json"

gcloud iam service-accounts keys create $keyFile --iam-account=$serviceAccountEmail

if (Test-Path $keyFile) {
    Write-Host "✅ Clave creada: $keyFile" -ForegroundColor Green
    
    # Mostrar el contenido para copiar
    Write-Host "`n📋 CONTENIDO PARA GITHUB SECRET (GCP_SA_KEY):" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Gray
    Get-Content $keyFile | Write-Host -ForegroundColor White
    Write-Host "=" * 60 -ForegroundColor Gray
    
    Write-Host "`n📝 INSTRUCCIONES:" -ForegroundColor Yellow
    Write-Host "1. Copia TODO el contenido JSON de arriba" -ForegroundColor White
    Write-Host "2. Ve a tu repositorio de GitHub" -ForegroundColor White
    Write-Host "3. Settings → Secrets and variables → Actions" -ForegroundColor White
    Write-Host "4. New repository secret:" -ForegroundColor White
    Write-Host "   - Name: GCP_SA_KEY" -ForegroundColor Green
    Write-Host "   - Secret: [pega el JSON completo]" -ForegroundColor Green
    Write-Host "5. Agrega otro secret:" -ForegroundColor White
    Write-Host "   - Name: GCP_PROJECT_ID" -ForegroundColor Green
    Write-Host "   - Secret: $ProjectId" -ForegroundColor Green
    
    Write-Host "`n🔒 SEGURIDAD:" -ForegroundColor Red
    Write-Host "   - NO subas el archivo $keyFile a Git" -ForegroundColor White
    Write-Host "   - Elimina el archivo después de copiarlo:" -ForegroundColor White
    Write-Host "     Remove-Item $keyFile" -ForegroundColor Gray
    
} else {
    Write-Host "❌ Error creando la clave" -ForegroundColor Red
}

Write-Host "`n✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "🚀 Ya puedes hacer push a GitHub para activar el CI/CD!" -ForegroundColor Cyan
