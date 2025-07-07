# 🚀 Frontend Admin - Deployment Ready

> Sistema de gestión académica con React + TypeScript + Tailwind CSS, optimizado para producción con Docker y Google Cloud Run.

## ✅ Estado del Proyecto

**CONFIGURACIÓN COMPLETADA Y VERIFICADA:**

- ✅ **Build de Vite**: Funciona correctamente
- ✅ **Docker Multi-stage**: Imagen optimizada construida exitosamente
- ✅ **Nginx**: Configurado con compresión gzip y headers de seguridad
- ✅ **Health Checks**: Implementados y funcionando
- ✅ **Puerto 8080**: Configurado para Cloud Run
- ✅ **CI/CD Pipeline**: GitHub Actions listo para deployment automático

## 🐳 Docker Local

### Prueba Rápida
```powershell
# Ejecutar script de prueba completo
.\test-docker.ps1
```

### Comandos Manuales
```powershell
# Build
docker build -t frontend-admin .

# Run
docker run -d -p 8080:8080 --name frontend-admin frontend-admin

# Test
# Abrir http://localhost:8080 en el navegador

# Cleanup
docker stop frontend-admin && docker rm frontend-admin
```

## ☁️ Despliegue a Google Cloud Run

### Opción 1: Script Automatizado
```powershell
# Desplegar con script
.\deploy-cloudrun.ps1 -ProjectId "tu-project-id"

# Con parámetros personalizados
.\deploy-cloudrun.ps1 -ProjectId "tu-project-id" -ServiceName "mi-app" -Region "us-east1"
```

### Opción 2: Comandos Manuales
```bash
# 1. Configurar proyecto
gcloud config set project TU_PROJECT_ID

# 2. Habilitar APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# 3. Build y deploy
gcloud builds submit --tag gcr.io/TU_PROJECT_ID/frontend-admin .
gcloud run deploy frontend-admin \
  --image gcr.io/TU_PROJECT_ID/frontend-admin \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080
```

## 🔄 CI/CD Automático con GitHub Actions

### Opción 1: Setup Automatizado (Recomendado)

```powershell
# Script que configura todo automáticamente
.\setup-gcp-cicd.ps1 -ProjectId "tu-project-id"

# El script:
# ✅ Configura el proyecto en gcloud
# ✅ Habilita las APIs necesarias  
# ✅ Crea la service account
# ✅ Asigna todos los permisos
# ✅ Genera la clave JSON
# ✅ Te muestra exactamente qué copiar a GitHub
```

### Opción 2: Setup Manual

#### Paso 1: Obtener la Clave de Service Account

```bash
# 1. Crear service account (si no existe)
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Deploy"

# 2. Asignar permisos necesarios
gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"

gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# 3. Crear y descargar la clave JSON
gcloud iam service-accounts keys create sa-key.json \
  --iam-account=github-actions@TU_PROJECT_ID.iam.gserviceaccount.com

# 4. Ver el contenido del archivo (para copiar)
cat sa-key.json
```

#### Paso 2: Agregar Secrets en GitHub

1. **Ve a tu repositorio en GitHub**
2. **Settings** → **Secrets and variables** → **Actions**
3. **Click en "New repository secret"**
4. **Agrega estos secrets:**

**Secret 1: GCP_PROJECT_ID**
- Name: `GCP_PROJECT_ID`
- Secret: `tu-project-id`

**Secret 2: GCP_SA_KEY**
- Name: `GCP_SA_KEY`
- Secret: **[Pega TODO el contenido del archivo sa-key.json]**

> ⚠️ **Importante**: Copia todo el contenido del archivo JSON, incluyendo las llaves `{}` y todos los campos.

#### Pasos Visuales en GitHub:

```
GitHub Repo → Settings (pestaña) → Secrets and variables (menú izquierdo) → Actions → New repository secret

┌─────────────────────────────────────┐
│ Name: GCP_PROJECT_ID                │
│ Secret: mi-proyecto-123             │
│ [Add secret]                        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Name: GCP_SA_KEY                    │
│ Secret: {                           │
│   "type": "service_account",        │
│   "project_id": "mi-proyecto-123",  │
│   "private_key_id": "abc123...",    │
│   "private_key": "-----BEGIN...",   │
│   ...resto del JSON...              │
│ }                                   │
│ [Add secret]                        │
└─────────────────────────────────────┘
```

#### Ejemplo del contenido de sa-key.json:
```json
{
  "type": "service_account",
  "project_id": "tu-project-id",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n",
  "client_email": "github-actions@tu-project-id.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
}
```

#### Paso 3: Verificar la Configuración

Una vez agregados los secrets:

1. **Ve a Actions** en tu repositorio
2. **Verifica que los secrets aparezcan** en Settings → Secrets and variables → Actions
3. **Los secrets aparecerán como:**
   ```
   GCP_PROJECT_ID    ••••••••••••
   GCP_SA_KEY        ••••••••••••
   ```
4. **Haz un push o crea un PR** para probar el pipeline

### Creación de Service Account

```bash
# Crear service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

# Asignar roles
gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"

gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Crear y descargar key
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions@TU_PROJECT_ID.iam.gserviceaccount.com
```

### Workflow Automático

El pipeline se ejecuta automáticamente cuando:
- 📤 **Push a main**: Deploy a producción
- 🔀 **Pull Request**: Build y tests
- 🏷️ **Release Tag**: Deploy con versionado

## 📁 Estructura de Archivos

```
├── 🐳 Dockerfile              # Imagen multi-stage optimizada
├── 🌐 nginx.conf              # Configuración Nginx con seguridad
├── ⚙️ .github/workflows/      # CI/CD Pipeline
├── 🧪 test-docker.ps1         # Script de prueba local
├── ☁️ deploy-cloudrun.ps1     # Script de deploy manual
├── 📋 verify-build.ps1        # Verificación de build
└── 🔧 setup-git.bat           # Configuración inicial de Git
```

## 🛠️ Scripts Útiles

| Script | Propósito |
|--------|-----------|
| `test-docker.ps1` | Prueba completa de Docker local |
| `deploy-cloudrun.ps1` | Deploy manual a Cloud Run |
| `setup-gcp-cicd.ps1` | **Configuración automática de GCP para CI/CD** |
| `verify-build.ps1` | Verifica que el build funciona |
| `setup-git.bat` | Configuración inicial de Git |

## 🔍 Verificación del Estado

### Build Local
```powershell
npm run build
# ✅ Debe completarse sin errores
```

### Docker
```powershell
docker build -t test-app .
docker run -p 8080:8080 test-app
# ✅ Debe servir la app en http://localhost:8080
```

### Health Check
```powershell
# El contenedor debe mostrar status "healthy"
docker ps
```

## 🌐 URLs de Acceso

- **Local Development**: http://localhost:5173 (Vite dev server)
- **Docker Local**: http://localhost:8080
- **Cloud Run**: Se genera automáticamente tras el deploy

## 📊 Características de Producción

- ⚡ **Vite Optimizado**: Build rápido con tree-shaking
- 🗜️ **Gzip Compression**: Reducción de tamaño de assets
- 🔒 **Security Headers**: Protección XSS, CSRF, etc.
- 🏥 **Health Checks**: Monitoreo automático
- 🔄 **Auto Scaling**: Escala automáticamente en Cloud Run
- 📈 **CDN Ready**: Cacheo optimizado de assets

## 🚨 Troubleshooting

### Error de Build
```powershell
# Limpiar node_modules y reinstalar
rm -rf node_modules
npm install
npm run build
```

### Error de Docker
```powershell
# Verificar que Docker está ejecutándose
docker --version

# Limpiar imágenes
docker system prune -f
```

### Error de Cloud Run
```bash
# Ver logs del servicio
gcloud run services logs read frontend-admin --region us-central1

# Verificar configuración
gcloud run services describe frontend-admin --region us-central1
```

### Errores de CI/CD (GitHub Actions)

#### Error: "Authentication failed"
```
Error: google-github-actions/auth failed with: retry function failed after 3 attempts
```
**Solución:**
1. Verifica que `GCP_SA_KEY` contenga el JSON completo
2. Asegúrate de que no hay espacios extra o caracteres especiales
3. Regenera la clave de service account:
```bash
gcloud iam service-accounts keys create new-sa-key.json \
  --iam-account=github-actions@TU_PROJECT_ID.iam.gserviceaccount.com
```

#### Error: "Permission denied"
```
Error: User does not have permission to access project
```
**Solución:**
1. Verifica que la service account tiene los roles correctos:
```bash
gcloud projects get-iam-policy TU_PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com"
```

2. Si faltan roles, agrégalos:
```bash
gcloud projects add-iam-policy-binding TU_PROJECT_ID \
  --member="serviceAccount:github-actions@TU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"
```

#### Error: "Invalid project ID"
```
Error: Invalid value for project_id
```
**Solución:**
1. Verifica que `GCP_PROJECT_ID` en GitHub secrets coincide exactamente con tu project ID
2. Obtén el project ID correcto:
```bash
gcloud config get-value project
```

#### Error: "Service not enabled"
```
Error: Cloud Build API has not been used in project
```
**Solución:**
```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
```

## 📋 Checklist Pre-Deploy

- [ ] Build local exitoso (`npm run build`)
- [ ] Docker build exitoso (`docker build -t test .`)
- [ ] Contenedor ejecuta correctamente (`docker run -p 8080:8080 test`)
- [ ] Health check funciona (status "healthy")
- [ ] Aplicación accesible en http://localhost:8080
- [ ] Secrets configurados en GitHub (si usas CI/CD)
- [ ] Service Account creada en GCP (si usas CI/CD)

## 🎯 Próximos Pasos

### Opción A: Deploy Manual Inmediato
```powershell
.\deploy-cloudrun.ps1 -ProjectId "tu-project-id"
```

### Opción B: Setup CI/CD Completo
```powershell
# 1. Configurar Google Cloud automáticamente
.\setup-gcp-cicd.ps1 -ProjectId "tu-project-id"

# 2. Seguir las instrucciones para agregar secrets a GitHub

# 3. Configurar Git y hacer push
.\setup-git.bat
```

### Después del Deploy
1. **Monitoreo**: Configura alertas en Google Cloud Console
2. **Custom Domain**: Conecta tu dominio personalizado  
3. **Variables de Entorno**: Configura variables específicas de producción
4. **Scaling**: Ajusta configuración de auto-scaling según necesidades

---

**¡Todo listo para producción! 🎉**

La aplicación está completamente configurada y verificada para deployment en Google Cloud Run.
