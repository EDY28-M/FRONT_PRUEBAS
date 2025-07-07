#!/bin/bash

# =============================================================================
# SCRIPT DE AUTOMATIZACIÓN - TEST Y DEPLOY
# =============================================================================
# Este script ejecuta todas las pruebas, hace commit de cambios y push automático
# Solo realiza el push si todas las pruebas pasan exitosamente
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
BRANCH="main"
COMMIT_MESSAGE_PREFIX="chore: automated test and deploy"

# Función para mostrar mensajes con colores
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para mostrar el banner
show_banner() {
    echo -e "${BLUE}"
    echo "============================================="
    echo "  🚀 AUTOMATED TEST & DEPLOY PIPELINE"
    echo "============================================="
    echo -e "${NC}"
}

# Función para verificar si estamos en un repositorio Git
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_error "No estás en un repositorio Git"
        exit 1
    fi
}

# Función para verificar si hay cambios para commitear
check_changes() {
    if git diff --quiet && git diff --staged --quiet; then
        log_warning "No hay cambios para commitear"
        return 1
    fi
    return 0
}

# Función para instalar dependencias si es necesario
install_dependencies() {
    log_info "Verificando dependencias..."
    
    if [ ! -d "node_modules" ]; then
        log_info "Instalando dependencias..."
        npm install
        if [ $? -ne 0 ]; then
            log_error "Error al instalar dependencias"
            exit 1
        fi
    else
        log_info "Dependencias ya instaladas"
    fi
}

# Función para ejecutar las pruebas
run_tests() {
    log_info "Ejecutando pruebas..."
    
    # Ejecutar pruebas con coverage
    npm run test:ci
    
    local test_exit_code=$?
    
    if [ $test_exit_code -eq 0 ]; then
        log_success "✅ Todas las pruebas pasaron exitosamente"
        return 0
    else
        log_error "❌ Las pruebas fallaron"
        return 1
    fi
}

# Función para ejecutar linting
run_linting() {
    log_info "Ejecutando linting..."
    
    if command -v eslint &> /dev/null; then
        npm run lint
        if [ $? -ne 0 ]; then
            log_warning "Se encontraron problemas de linting. Intentando auto-fix..."
            npm run lint:fix
            if [ $? -ne 0 ]; then
                log_error "No se pudieron corregir automáticamente todos los problemas de linting"
                return 1
            fi
        fi
    else
        log_warning "ESLint no está configurado, saltando linting"
    fi
    
    log_success "✅ Linting completado"
    return 0
}

# Función para hacer commit de los cambios
commit_changes() {
    log_info "Preparando commit..."
    
    # Mostrar los cambios que se van a commitear
    echo -e "${YELLOW}Cambios a commitear:${NC}"
    git status --porcelain
    
    # Agregar todos los cambios
    git add .
    
    # Crear mensaje de commit con timestamp
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local commit_message="$COMMIT_MESSAGE_PREFIX - $timestamp"
    
    # Permitir al usuario personalizar el mensaje
    if [ "$1" != "--auto" ]; then
        echo -e "${YELLOW}Mensaje de commit por defecto:${NC} $commit_message"
        read -p "¿Quieres usar un mensaje personalizado? (Enter para usar el por defecto): " custom_message
        if [ ! -z "$custom_message" ]; then
            commit_message="$custom_message"
        fi
    fi
    
    # Hacer commit
    git commit -m "$commit_message"
    
    if [ $? -eq 0 ]; then
        log_success "✅ Commit realizado exitosamente"
        return 0
    else
        log_error "❌ Error al hacer commit"
        return 1
    fi
}

# Función para hacer push
push_changes() {
    log_info "Haciendo push a la rama $BRANCH..."
    
    # Verificar si estamos en la rama correcta
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "$BRANCH" ]; then
        log_warning "Estás en la rama '$current_branch', cambiando a '$BRANCH'"
        git checkout $BRANCH
        if [ $? -ne 0 ]; then
            log_error "No se pudo cambiar a la rama $BRANCH"
            return 1
        fi
    fi
    
    # Hacer push
    git push origin $BRANCH
    
    if [ $? -eq 0 ]; then
        log_success "✅ Push realizado exitosamente"
        log_info "El pipeline CI/CD se ejecutará automáticamente en GitHub Actions"
        return 0
    else
        log_error "❌ Error al hacer push"
        return 1
    fi
}

# Función para mostrar el resumen final
show_summary() {
    echo -e "${GREEN}"
    echo "============================================="
    echo "  ✅ PIPELINE COMPLETADO EXITOSAMENTE"
    echo "============================================="
    echo "• Pruebas ejecutadas: ✅"
    echo "• Linting ejecutado: ✅"
    echo "• Cambios commiteados: ✅"
    echo "• Push realizado: ✅"
    echo "• CI/CD activado: ✅"
    echo ""
    echo "🌐 Revisa el progreso en:"
    echo "   GitHub Actions: https://github.com/tu-usuario/tu-repo/actions"
    echo "   Cloud Run: https://console.cloud.google.com/run"
    echo "============================================="
    echo -e "${NC}"
}

# Función para limpiar en caso de error
cleanup_on_error() {
    log_error "Pipeline interrumpido debido a errores"
    echo -e "${RED}"
    echo "============================================="
    echo "  ❌ PIPELINE FALLIDO"
    echo "============================================="
    echo "• Verifica los errores mostrados arriba"
    echo "• Corrige los problemas y vuelve a ejecutar"
    echo "• Los cambios NO han sido enviados al repositorio"
    echo "============================================="
    echo -e "${NC}"
}

# Función principal
main() {
    show_banner
    
    # Verificar argumentos
    AUTO_MODE=false
    if [ "$1" == "--auto" ]; then
        AUTO_MODE=true
        log_info "Modo automático activado"
    fi
    
    # Verificar que estamos en un repositorio Git
    check_git_repo
    
    # Verificar si hay cambios
    if ! check_changes; then
        log_info "No hay cambios para procesar. Saliendo..."
        exit 0
    fi
    
    # Instalar dependencias
    install_dependencies
    
    # Ejecutar linting
    if ! run_linting; then
        cleanup_on_error
        exit 1
    fi
    
    # Ejecutar pruebas
    if ! run_tests; then
        cleanup_on_error
        exit 1
    fi
    
    # Hacer commit
    if $AUTO_MODE; then
        if ! commit_changes --auto; then
            cleanup_on_error
            exit 1
        fi
    else
        if ! commit_changes; then
            cleanup_on_error
            exit 1
        fi
    fi
    
    # Hacer push
    if ! push_changes; then
        cleanup_on_error
        exit 1
    fi
    
    # Mostrar resumen
    show_summary
}

# Manejar interrupciones (Ctrl+C)
trap cleanup_on_error INT

# Ejecutar función principal
main "$@"
