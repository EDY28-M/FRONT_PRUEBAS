# 🚀 CONFIGURACIÓN COMPLETA DE CI/CD CON CLOUD RUN

## ✅ Archivos Creados/Modificados

### 📁 Configuración de Docker
- `Dockerfile` - Imagen multi-stage optimizada para producción
- `nginx.conf` - Configuración de Nginx con optimizaciones
- `.dockerignore` - Archivos excluidos del build de Docker

### 📁 Configuración de CI/CD
- `.github/workflows/deploy.yml` - Pipeline de deployment automático
- `.github/workflows/pr-review.yml` - Pipeline de revisión de PRs
- `cloudrun.yaml` - Configuración de Cloud Run

### 📁 Scripts de Deployment
- `deploy.ps1` - Script de deployment para Windows
- `deploy.sh` - Script de deployment para Linux/macOS
- `verify-build.ps1` - Verificación del build para Windows
- `clean.bat` - Script de limpieza para Windows

### 📁 Configuración de Entorno
- `.env` - Variables de entorno para desarrollo (actualizado)
- `.env.production` - Variables de entorno para producción
- `src/vite-env.d.ts` - Tipos TypeScript para variables de entorno
- `src/lib/config.ts` - Configuración centralizada

### 📁 Documentación
- `DEPLOYMENT_GUIDE.md` - Guía completa de configuración
- `BUILD_VERIFICATION.md` - Guía de verificación del build
- `README.md` - Documentación actualizada

### 📁 Configuración de Build
- `vite.config.ts` - Configuración optimizada de Vite
- `package.json` - Scripts adicionales para deployment
- `.gitignore` - Archivos excluidos del repositorio

## 🔧 PASOS PARA CONFIGURAR EL DEPLOYMENT

### 1. Preparar Google Cloud Platform

```bash
# Crear proyecto (opcional)
gcloud projects create tu-project-id

# Habilitar APIs
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Crear cuenta de servicio
gcloud iam service-accounts create github-actions \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions"

# Asignar roles
gcloud projects add-iam-policy-binding tu-project-id \
    --member="serviceAccount:github-actions@tu-project-id.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding tu-project-id \
    --member="serviceAccount:github-actions@tu-project-id.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding tu-project-id \
    --member="serviceAccount:github-actions@tu-project-id.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding tu-project-id \
    --member="serviceAccount:github-actions@tu-project-id.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Crear clave JSON
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@tu-project-id.iam.gserviceaccount.com
```

### 2. Configurar GitHub Secrets

Ve a tu repositorio → Settings → Secrets and variables → Actions:

#### Secrets requeridos:
- `GCP_PROJECT_ID`: ID de tu proyecto de Google Cloud
- `GCP_SA_KEY`: Contenido completo del archivo `key.json`

### 3. Verificar el Build Localmente

```powershell
# Windows
.\verify-build.ps1

# Linux/macOS
chmod +x verify-build.sh && ./verify-build.sh
```

### 4. Deployment Manual (Opcional)

```powershell
# Windows
.\deploy.ps1 -ProjectId "tu-project-id"

# Linux/macOS
./deploy.sh tu-project-id
```

### 5. Deployment Automático

```bash
# Hacer commit y push para disparar el deployment
git add .
git commit -m "Configure CI/CD with Cloud Run"
git push origin main
```

## 📊 CARACTERÍSTICAS DEL DEPLOYMENT

### ✅ Optimizaciones Implementadas
- **Build multi-stage** para reducir tamaño de imagen
- **Nginx optimizado** con cache y compresión
- **Health checks** para monitoreo
- **Variables de entorno** seguras
- **Rollback automático** en caso de errores
- **Escalado automático** (0-10 instancias)

### ✅ Configuración de Producción
- **CPU**: 1 core
- **Memoria**: 512MB
- **Concurrencia**: 80 requests simultáneos
- **Timeout**: 300 segundos
- **Instancias mínimas**: 0 (scale-to-zero)
- **Instancias máximas**: 10

### ✅ Seguridad
- **Contenedor sin root**
- **Headers de seguridad**
- **HTTPS forzado**
- **Acceso público controlado**

## 🚨 TROUBLESHOOTING

### Error: "Permission denied"
- Verifica que la cuenta de servicio tenga todos los roles necesarios
- Revisa que el archivo JSON esté completo en GitHub Secrets

### Error: "Image not found"
- Verifica que Artifact Registry esté habilitado
- Asegúrate de que la región sea correcta (us-central1)

### Error: "Build failed"
- Ejecuta `.\verify-build.ps1` localmente
- Revisa los logs en GitHub Actions

### Error: "Service unavailable"
- Verifica que el puerto 8080 esté expuesto
- Revisa la configuración de nginx.conf

## 🎯 PRÓXIMOS PASOS

1. **Configurar dominio personalizado** (opcional)
2. **Implementar monitoreo** con Cloud Monitoring
3. **Configurar alertas** para errores
4. **Optimizar costos** con Cloud Scheduler
5. **Implementar staging environment**

## 📞 SOPORTE

Si tienes problemas:
1. Revisa la documentación en `DEPLOYMENT_GUIDE.md`
2. Ejecuta `.\verify-build.ps1` para diagnóstico
3. Revisa los logs en GitHub Actions
4. Consulta la documentación de Cloud Run

¡Tu aplicación está lista para producción! 🚀
