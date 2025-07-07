#!/bin/bash

# Script para deployment local a Cloud Run
# Uso: ./deploy.sh [PROJECT_ID]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que se proporcione PROJECT_ID
if [ -z "$1" ]; then
    print_error "Usage: $0 <PROJECT_ID>"
    exit 1
fi

PROJECT_ID=$1
SERVICE_NAME="frontend-admin"
REGION="us-central1"

print_message "Starting deployment to Cloud Run..."
print_message "Project ID: $PROJECT_ID"
print_message "Service: $SERVICE_NAME"
print_message "Region: $REGION"

# Verificar que gcloud esté instalado
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

# Configurar proyecto
print_message "Setting up project..."
gcloud config set project $PROJECT_ID

# Habilitar APIs necesarias
print_message "Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Configurar autenticación de Docker
print_message "Configuring Docker authentication..."
gcloud auth configure-docker us-central1-docker.pkg.dev

# Crear repositorio de Artifact Registry si no existe
print_message "Creating Artifact Registry repository..."
gcloud artifacts repositories create $SERVICE_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for $SERVICE_NAME" || true

# Build de la imagen Docker
print_message "Building Docker image..."
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$SERVICE_NAME/$SERVICE_NAME:latest .

# Push de la imagen
print_message "Pushing Docker image..."
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$SERVICE_NAME/$SERVICE_NAME:latest

# Deploy a Cloud Run
print_message "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=$REGION-docker.pkg.dev/$PROJECT_ID/$SERVICE_NAME/$SERVICE_NAME:latest \
    --region=$REGION \
    --platform=managed \
    --allow-unauthenticated \
    --port=8080 \
    --cpu=1 \
    --memory=512Mi \
    --min-instances=0 \
    --max-instances=10 \
    --concurrency=80 \
    --timeout=300 \
    --set-env-vars="VITE_API_URL=https://34.60.233.211/api,VITE_BACKEND_HTTPS=https://34.60.233.211/api,VITE_BACKEND_HTTP=https://34.60.233.211/api,VITE_SWAGGER_URL=https://34.60.233.211/swagger,VITE_DEV_MODE=false,VITE_ENABLE_DEVTOOLS=false"

# Obtener URL del servicio
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

print_message "Deployment completed successfully!"
print_message "Service URL: $SERVICE_URL"
print_message "You can access your application at: $SERVICE_URL"

# Opcional: abrir en el navegador (solo en macOS/Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "Do you want to open the URL in your browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open $SERVICE_URL
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    read -p "Do you want to open the URL in your browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open $SERVICE_URL
    fi
fi
