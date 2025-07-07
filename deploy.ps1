# Script para deployment a Cloud Run desde Windows PowerShell
# Uso: .\deploy.ps1 -ProjectId "tu-project-id"

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId
)

$ServiceName = "frontend-admin"
$Region = "us-central1"

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "Green"
    )
    Write-Host "[INFO] $Message" -ForegroundColor $Color
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

Write-ColorMessage "Starting deployment to Cloud Run..."
Write-ColorMessage "Project ID: $ProjectId"
Write-ColorMessage "Service: $ServiceName"
Write-ColorMessage "Region: $Region"

# Verificar que gcloud esté instalado
try {
    $null = Get-Command gcloud -ErrorAction Stop
    Write-ColorMessage "gcloud CLI found"
} catch {
    Write-ErrorMessage "gcloud CLI is not installed. Please install it first."
    Write-Host "Download from: https://cloud.google.com/sdk/docs/install"
    exit 1
}

# Verificar que Docker esté instalado
try {
    $null = Get-Command docker -ErrorAction Stop
    Write-ColorMessage "Docker found"
} catch {
    Write-ErrorMessage "Docker is not installed. Please install it first."
    Write-Host "Download from: https://www.docker.com/products/docker-desktop"
    exit 1
}

# Configurar proyecto
Write-ColorMessage "Setting up project..."
gcloud config set project $ProjectId

# Habilitar APIs necesarias
Write-ColorMessage "Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Configurar autenticación de Docker
Write-ColorMessage "Configuring Docker authentication..."
gcloud auth configure-docker us-central1-docker.pkg.dev

# Crear repositorio de Artifact Registry si no existe
Write-ColorMessage "Creating Artifact Registry repository..."
$createRepoResult = gcloud artifacts repositories create $ServiceName `
    --repository-format=docker `
    --location=$Region `
    --description="Docker repository for $ServiceName" 2>&1

if ($LASTEXITCODE -ne 0 -and $createRepoResult -notlike "*already exists*") {
    Write-ErrorMessage "Failed to create Artifact Registry repository"
    exit 1
}

# Build de la imagen Docker
Write-ColorMessage "Building Docker image..."
$imageName = "$Region-docker.pkg.dev/$ProjectId/$ServiceName/${ServiceName}:latest"
docker build -t $imageName .

if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "Docker build failed"
    exit 1
}

# Push de la imagen
Write-ColorMessage "Pushing Docker image..."
docker push $imageName

if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "Docker push failed"
    exit 1
}

# Deploy a Cloud Run
Write-ColorMessage "Deploying to Cloud Run..."
gcloud run deploy $ServiceName `
    --image=$imageName `
    --region=$Region `
    --platform=managed `
    --allow-unauthenticated `
    --port=8080 `
    --cpu=1 `
    --memory=512Mi `
    --min-instances=0 `
    --max-instances=10 `
    --concurrency=80 `
    --timeout=300 `
    --set-env-vars="VITE_API_URL=https://34.60.233.211/api,VITE_BACKEND_HTTPS=https://34.60.233.211/api,VITE_BACKEND_HTTP=https://34.60.233.211/api,VITE_SWAGGER_URL=https://34.60.233.211/swagger,VITE_DEV_MODE=false,VITE_ENABLE_DEVTOOLS=false"

if ($LASTEXITCODE -ne 0) {
    Write-ErrorMessage "Cloud Run deployment failed"
    exit 1
}

# Obtener URL del servicio
Write-ColorMessage "Getting service URL..."
$ServiceUrl = gcloud run services describe $ServiceName --region=$Region --format="value(status.url)"

Write-ColorMessage "Deployment completed successfully!" -Color Green
Write-ColorMessage "Service URL: $ServiceUrl" -Color Cyan
Write-ColorMessage "You can access your application at: $ServiceUrl" -Color Cyan

# Preguntar si abrir en el navegador
$openBrowser = Read-Host "Do you want to open the URL in your browser? (y/n)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process $ServiceUrl
}
