# Script para desplegar a Google Cloud Run
# Prerrequisitos: gcloud CLI instalado y autenticado
# Uso: .\deploy-cloudrun.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "frontend-admin",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-central1",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest"
)

Write-Host "☁️  Iniciando despliegue a Google Cloud Run..." -ForegroundColor Cyan
Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "   Project ID: $ProjectId" -ForegroundColor White
Write-Host "   Service: $ServiceName" -ForegroundColor White
Write-Host "   Region: $Region" -ForegroundColor White
Write-Host "   Image Tag: $ImageTag" -ForegroundColor White

# Verificar que gcloud está instalado
try {
    gcloud version 2>$null | Out-Null
    Write-Host "✅ gcloud CLI encontrado" -ForegroundColor Green
}
catch {
    Write-Host "❌ gcloud CLI no encontrado. Instala Google Cloud SDK primero." -ForegroundColor Red
    exit 1
}

# Configurar proyecto
Write-Host "🔧 Configurando proyecto..." -ForegroundColor Yellow
gcloud config set project $ProjectId

# Habilitar APIs necesarias
Write-Host "🔌 Habilitando APIs necesarias..." -ForegroundColor Yellow
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Configurar Docker para usar gcloud como credential helper
Write-Host "🐳 Configurando autenticación de Docker..." -ForegroundColor Yellow
gcloud auth configure-docker

# Build y push de la imagen
$imageName = "gcr.io/$ProjectId/$ServiceName"
$fullImageName = "$imageName`:$ImageTag"

Write-Host "📦 Construyendo y subiendo imagen..." -ForegroundColor Yellow
Write-Host "   Imagen: $fullImageName" -ForegroundColor White

# Build usando Cloud Build (recomendado)
gcloud builds submit --tag $fullImageName .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagen construida y subida exitosamente" -ForegroundColor Green
    
    # Desplegar a Cloud Run
    Write-Host "🚀 Desplegando a Cloud Run..." -ForegroundColor Yellow
    gcloud run deploy $ServiceName `
        --image $fullImageName `
        --platform managed `
        --region $Region `
        --allow-unauthenticated `
        --port 8080 `
        --memory 512Mi `
        --cpu 1 `
        --min-instances 0 `
        --max-instances 10 `
        --timeout 300s
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Despliegue exitoso!" -ForegroundColor Green
        
        # Obtener URL del servicio
        $serviceUrl = gcloud run services describe $ServiceName --region $Region --format "value(status.url)"
        Write-Host "🌐 URL de la aplicación: $serviceUrl" -ForegroundColor Green
        
        # Mostrar información del servicio
        Write-Host "📊 Información del servicio:" -ForegroundColor Yellow
        gcloud run services describe $ServiceName --region $Region
        
    } else {
        Write-Host "❌ Error en el despliegue a Cloud Run" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Error en la construcción de la imagen" -ForegroundColor Red
}

Write-Host "`n📋 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   Ver logs: gcloud run services logs read $ServiceName --region $Region" -ForegroundColor White
Write-Host "   Ver servicios: gcloud run services list" -ForegroundColor White
Write-Host "   Eliminar servicio: gcloud run services delete $ServiceName --region $Region" -ForegroundColor White
