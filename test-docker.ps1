# Script para probar el Docker build y deployment
# Uso: .\test-docker.ps1

Write-Host "🐳 Iniciando prueba de Docker..." -ForegroundColor Cyan

# Build de la imagen
Write-Host "📦 Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t frontend-admin-test .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build exitoso" -ForegroundColor Green
    
    # Ejecutar contenedor
    Write-Host "🚀 Ejecutando contenedor..." -ForegroundColor Yellow
    $containerId = docker run -d -p 8080:8080 --name frontend-admin-test frontend-admin-test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Contenedor iniciado: $containerId" -ForegroundColor Green
        
        # Esperar que el contenedor esté listo
        Write-Host "⏳ Esperando que el contenedor esté listo..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Verificar health check
        $health = docker inspect --format='{{.State.Health.Status}}' frontend-admin-test
        Write-Host "🏥 Health status: $health" -ForegroundColor Cyan
        
        # Probar conectividad
        Write-Host "🌐 Probando conectividad..." -ForegroundColor Yellow
        try {
            $response = Invoke-WebRequest -Uri http://localhost:8080 -Method Head -TimeoutSec 10
            Write-Host "✅ Servidor responde: $($response.StatusCode)" -ForegroundColor Green
            Write-Host "🔗 La aplicación está disponible en: http://localhost:8080" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error de conectividad: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Mostrar logs recientes
        Write-Host "📝 Logs del contenedor:" -ForegroundColor Yellow
        docker logs --tail 10 frontend-admin-test
        
        # Instrucciones de limpieza
        Write-Host "`n🧹 Para limpiar ejecuta:" -ForegroundColor Cyan
        Write-Host "docker stop frontend-admin-test && docker rm frontend-admin-test" -ForegroundColor White
        
    } else {
        Write-Host "❌ Error al ejecutar contenedor" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Error en el build" -ForegroundColor Red
}
