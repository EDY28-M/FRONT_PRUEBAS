#!/bin/bash

# Script para configurar Google Cloud para CI/CD
# Uso: ./setup-gcp-cicd.sh PROJECT_ID [SERVICE_ACCOUNT_NAME]

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Parámetros
PROJECT_ID=$1
SERVICE_ACCOUNT_NAME=${2:-"github-actions"}

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ Error: Debes proporcionar un PROJECT_ID${NC}"
    echo "Uso: ./setup-gcp-cicd.sh PROJECT_ID [SERVICE_ACCOUNT_NAME]"
    echo "Ejemplo: ./setup-gcp-cicd.sh ascendant-altar-457900-v4"
    exit 1
fi

echo -e "${CYAN}☁️  Configurando Google Cloud para CI/CD...${NC}"
echo -e "${YELLOW}📋 Configuración:${NC}"
echo -e "${WHITE}   Project ID: $PROJECT_ID${NC}"
echo -e "${WHITE}   Service Account: $SERVICE_ACCOUNT_NAME${NC}"

# Verificar que gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI no encontrado. Instala Google Cloud SDK primero.${NC}"
    echo -e "${YELLOW}   Descarga desde: https://cloud.google.com/sdk${NC}"
    exit 1
fi

echo -e "${GREEN}✅ gcloud CLI encontrado${NC}"

# Configurar proyecto
echo -e "\n${YELLOW}🔧 Configurando proyecto...${NC}"
gcloud config set project $PROJECT_ID

# Verificar que el proyecto existe
if ! gcloud projects describe $PROJECT_ID &>/dev/null; then
    echo -e "${RED}❌ Proyecto '$PROJECT_ID' no encontrado o no tienes acceso${NC}"
    echo -e "${YELLOW}   Verifica el Project ID o crea el proyecto primero${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Proyecto verificado: $PROJECT_ID${NC}"

# Habilitar APIs necesarias
echo -e "\n${YELLOW}🔌 Habilitando APIs necesarias...${NC}"
APIS=(
    "cloudbuild.googleapis.com"
    "run.googleapis.com"
    "containerregistry.googleapis.com"
)

for api in "${APIS[@]}"; do
    echo -e "${GRAY}   Habilitando $api...${NC}"
    gcloud services enable $api
done

echo -e "${GREEN}✅ APIs habilitadas${NC}"

# Crear service account
echo -e "\n${YELLOW}👤 Creando service account...${NC}"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# Verificar si ya existe
if gcloud iam service-accounts list --filter="email:$SERVICE_ACCOUNT_EMAIL" --format="value(email)" | grep -q "$SERVICE_ACCOUNT_EMAIL"; then
    echo -e "${YELLOW}⚠️  Service account ya existe: $SERVICE_ACCOUNT_EMAIL${NC}"
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="GitHub Actions Deploy"
    echo -e "${GREEN}✅ Service account creada: $SERVICE_ACCOUNT_EMAIL${NC}"
fi

# Asignar roles necesarios
echo -e "\n${YELLOW}🔐 Asignando permisos...${NC}"
ROLES=(
    "roles/cloudbuild.builds.builder"
    "roles/run.admin"
    "roles/storage.admin"
    "roles/iam.serviceAccountUser"
)

for role in "${ROLES[@]}"; do
    echo -e "${GRAY}   Asignando $role...${NC}"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$role" >/dev/null
done

echo -e "${GREEN}✅ Permisos asignados${NC}"

# Crear clave JSON
echo -e "\n${YELLOW}🔑 Creando clave de acceso...${NC}"
KEY_FILE="sa-key-$PROJECT_ID.json"

gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

if [ -f "$KEY_FILE" ]; then
    echo -e "${GREEN}✅ Clave creada: $KEY_FILE${NC}"
    
    # Mostrar el contenido para copiar
    echo -e "\n${CYAN}📋 CONTENIDO PARA GITHUB SECRET (GCP_SA_KEY):${NC}"
    echo "============================================================"
    cat $KEY_FILE
    echo "============================================================"
    
    echo -e "\n${YELLOW}📝 INSTRUCCIONES:${NC}"
    echo -e "${WHITE}1. Copia TODO el contenido JSON de arriba${NC}"
    echo -e "${WHITE}2. Ve a tu repositorio de GitHub${NC}"
    echo -e "${WHITE}3. Settings → Secrets and variables → Actions${NC}"
    echo -e "${WHITE}4. New repository secret:${NC}"
    echo -e "${GREEN}   - Name: GCP_SA_KEY${NC}"
    echo -e "${GREEN}   - Secret: [pega el JSON completo]${NC}"
    echo -e "${WHITE}5. Agrega otro secret:${NC}"
    echo -e "${GREEN}   - Name: GCP_PROJECT_ID${NC}"
    echo -e "${GREEN}   - Secret: $PROJECT_ID${NC}"
    
    echo -e "\n${RED}🔒 SEGURIDAD:${NC}"
    echo -e "${WHITE}   - NO subas el archivo $KEY_FILE a Git${NC}"
    echo -e "${WHITE}   - Elimina el archivo después de copiarlo:${NC}"
    echo -e "${GRAY}     rm $KEY_FILE${NC}"
    
else
    echo -e "${RED}❌ Error creando la clave${NC}"
fi

echo -e "\n${GREEN}✅ CONFIGURACIÓN COMPLETADA${NC}"
echo -e "${CYAN}🚀 Ya puedes hacer push a GitHub para activar el CI/CD!${NC}"