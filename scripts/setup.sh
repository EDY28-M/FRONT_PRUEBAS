#!/bin/bash

# =============================================================================
# SCRIPT DE CONFIGURACIÓN INICIAL
# =============================================================================
# Configura los scripts de automatización y crea alias
# =============================================================================

echo "🚀 Configurando scripts de automatización..."

# Hacer scripts ejecutables
chmod +x scripts/test-and-deploy.sh
chmod +x scripts/quick-deploy.sh
chmod +x scripts/setup.sh

echo "✅ Scripts hechos ejecutables"

# Verificar dependencias
echo "🔍 Verificando dependencias..."

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    echo "   Descárgalo desde: https://nodejs.org/"
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado"
    exit 1
fi

# Verificar Git
if ! command -v git &> /dev/null; then
    echo "❌ Git no está instalado"
    echo "   Descárgalo desde: https://git-scm.com/"
    exit 1
fi

echo "✅ Dependencias verificadas"

# Crear alias si el usuario quiere
echo ""
echo "¿Quieres crear alias para los scripts? (y/n)"
read -p "Esto te permitirá usar 'deploy' y 'quickdeploy' desde cualquier lugar: " create_alias

if [[ $create_alias == "y" || $create_alias == "Y" ]]; then
    # Detectar shell
    if [[ $SHELL == *"bash"* ]]; then
        echo "# Alias para scripts de automatización" >> ~/.bashrc
        echo "alias deploy='./scripts/test-and-deploy.sh'" >> ~/.bashrc
        echo "alias quickdeploy='./scripts/quick-deploy.sh'" >> ~/.bashrc
        echo "✅ Alias agregados a ~/.bashrc"
        echo "   Ejecuta 'source ~/.bashrc' o reinicia tu terminal"
    elif [[ $SHELL == *"zsh"* ]]; then
        echo "# Alias para scripts de automatización" >> ~/.zshrc
        echo "alias deploy='./scripts/test-and-deploy.sh'" >> ~/.zshrc
        echo "alias quickdeploy='./scripts/quick-deploy.sh'" >> ~/.zshrc
        echo "✅ Alias agregados a ~/.zshrc"
        echo "   Ejecuta 'source ~/.zshrc' o reinicia tu terminal"
    else
        echo "⚠️  Shell no reconocido, crea los alias manualmente"
    fi
fi

# Instalar dependencias del proyecto
echo ""
echo "🔧 Instalando dependencias del proyecto..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencias instaladas correctamente"
else
    echo "❌ Error al instalar dependencias"
    exit 1
fi

# Ejecutar una prueba inicial
echo ""
echo "🧪 Ejecutando pruebas iniciales..."
npm run test:ci

if [ $? -eq 0 ]; then
    echo "✅ Pruebas iniciales pasaron"
else
    echo "⚠️  Algunas pruebas fallaron, revisa el código"
fi

echo ""
echo "============================================="
echo "  ✅ CONFIGURACIÓN COMPLETADA"
echo "============================================="
echo "Scripts disponibles:"
echo "• ./scripts/test-and-deploy.sh (o 'deploy')"
echo "• ./scripts/quick-deploy.sh (o 'quickdeploy')"
echo ""
echo "Para usar los scripts:"
echo "1. Haz cambios en tu código"
echo "2. Ejecuta: ./scripts/quick-deploy.sh"
echo "3. ¡Listo! El código se desplegará automáticamente"
echo ""
echo "Lee scripts/README.md para más información"
echo "============================================="
