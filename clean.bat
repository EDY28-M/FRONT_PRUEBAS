@echo off
REM Script de limpieza para el proyecto Frontend Admin
REM Limpia cache, builds y archivos temporales

echo ==============================================
echo    🧹 LIMPIEZA DEL PROYECTO FRONTEND ADMIN
echo ==============================================
echo.

echo [INFO] Limpiando directorios de build...
if exist "dist" (
    rmdir /s /q "dist"
    echo ✅ Directorio 'dist' eliminado
) else (
    echo ℹ️  Directorio 'dist' no existe
)

echo.
echo [INFO] Limpiando cache de npm...
npm cache clean --force
echo ✅ Cache de npm limpiado

echo.
echo [INFO] Limpiando node_modules...
if exist "node_modules" (
    rmdir /s /q "node_modules"
    echo ✅ Directorio 'node_modules' eliminado
) else (
    echo ℹ️  Directorio 'node_modules' no existe
)

echo.
echo [INFO] Limpiando archivos de lock...
if exist "package-lock.json" (
    del "package-lock.json"
    echo ✅ Archivo 'package-lock.json' eliminado
)

echo.
echo [INFO] Reinstalando dependencias...
npm install
echo ✅ Dependencias reinstaladas

echo.
echo [INFO] Limpiando imágenes Docker huérfanas...
docker image prune -f >nul 2>&1
echo ✅ Imágenes Docker huérfanas eliminadas

echo.
echo ==============================================
echo ✅ LIMPIEZA COMPLETADA EXITOSAMENTE
echo ==============================================
echo.
echo El proyecto está listo para desarrollo o deployment.
echo.
pause
