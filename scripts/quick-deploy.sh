#!/bin/bash

# =============================================================================
# SCRIPT RÁPIDO - TEST Y PUSH
# =============================================================================
# Versión simplificada para uso diario
# =============================================================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Ejecutando pipeline rápido...${NC}"

# Verificar si estamos en un repositorio Git
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${RED}❌ No estás en un repositorio Git${NC}"
    exit 1
fi

# Verificar si hay cambios
if git diff --quiet && git diff --staged --quiet; then
    echo -e "${YELLOW}ℹ️  No hay cambios para procesar${NC}"
    exit 0
fi

# Ejecutar pruebas
echo -e "${YELLOW}🧪 Ejecutando pruebas...${NC}"
npm run test:ci

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Las pruebas fallaron. Abortando push.${NC}"
    exit 1
fi

# Ejecutar linting si existe
if command -v eslint &> /dev/null; then
    echo -e "${YELLOW}🔍 Ejecutando linting...${NC}"
    npm run lint:fix
fi

# Agregar cambios y hacer commit
echo -e "${YELLOW}📝 Haciendo commit...${NC}"
git add .

# Mensaje de commit con timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
commit_message="feat: automated update - $timestamp"

# Permitir mensaje personalizado
if [ "$1" != "--auto" ]; then
    echo -e "${YELLOW}Mensaje por defecto: $commit_message${NC}"
    read -p "Mensaje personalizado (Enter para usar el por defecto): " custom_message
    if [ ! -z "$custom_message" ]; then
        commit_message="$custom_message"
    fi
fi

git commit -m "$commit_message"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al hacer commit${NC}"
    exit 1
fi

# Hacer push
echo -e "${YELLOW}🚀 Haciendo push...${NC}"
git push origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ¡Pipeline completado exitosamente!${NC}"
    echo -e "${GREEN}🌐 Revisa el progreso en GitHub Actions${NC}"
else
    echo -e "${RED}❌ Error al hacer push${NC}"
    exit 1
fi
