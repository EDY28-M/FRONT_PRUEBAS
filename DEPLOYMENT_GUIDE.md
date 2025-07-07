# Guía de Configuración para CI/CD con GitHub Actions y Cloud Run

## Configuración de Secrets en GitHub

Para que el CI/CD funcione correctamente, necesitas configurar los siguientes secrets en tu repositorio de GitHub:

### 1. Configurar Secrets en GitHub

Ve a tu repositorio → Settings → Secrets and variables → Actions, y agrega:

#### `GCP_PROJECT_ID`
- **Valor**: El ID de tu proyecto de Google Cloud Platform
- **Ejemplo**: `mi-proyecto-123456`

#### `GCP_SA_KEY`
- **Valor**: La clave JSON de la cuenta de servicio de Google Cloud
- **Cómo obtenerla**:
  1. Ve a la consola de Google Cloud
  2. IAM & Admin → Service Accounts
  3. Crea una nueva cuenta de servicio o usa una existente
  4. Asigna los roles necesarios (ver más abajo)
  5. Genera una clave JSON y cópiala completa

### 2. Roles necesarios para la Service Account

La cuenta de servicio debe tener los siguientes roles:

- `Cloud Run Admin`
- `Artifact Registry Administrator`
- `Storage Admin`
- `Service Account User`

### 3. Comandos para configurar desde Google Cloud CLI

```bash
# 1. Crear proyecto (si no existe)
gcloud projects create [PROJECT_ID]

# 2. Habilitar APIs necesarias
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# 3. Crear cuenta de servicio
gcloud iam service-accounts create github-actions \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions"

# 4. Asignar roles
gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:github-actions@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:github-actions@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:github-actions@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:github-actions@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# 5. Crear clave JSON
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@[PROJECT_ID].iam.gserviceaccount.com
```

### 4. Verificar la configuración

Después de configurar los secrets, haz un push a la rama `main` o `master` para probar el deployment:

```bash
git add .
git commit -m "Configure CI/CD with Cloud Run"
git push origin main
```

### 5. Monitorear el deployment

- Ve a Actions en tu repositorio de GitHub para ver el progreso
- Una vez completado, encontrarás la URL de tu aplicación en los logs
- La URL tendrá el formato: `https://frontend-admin-[HASH]-uc.a.run.app`

### 6. Configurar dominio personalizado (opcional)

Si quieres usar un dominio personalizado:

1. Ve a Cloud Run en Google Cloud Console
2. Selecciona tu servicio
3. Ve a la pestaña "Manage Custom Domains"
4. Sigue las instrucciones para mapear tu dominio

### 7. Variables de entorno en producción

Las variables de entorno se configuran automáticamente en el workflow, pero puedes modificarlas en:

- `cloudrun.yaml` para configuración manual
- `.github/workflows/deploy.yml` para CI/CD automático

### 8. Troubleshooting

Si el deployment falla:

1. Verifica que los secrets estén configurados correctamente
2. Revisa los logs en GitHub Actions
3. Verifica que las APIs estén habilitadas en Google Cloud
4. Asegúrate de que la cuenta de servicio tenga los permisos necesarios

### 9. Costos estimados

- Cloud Run: ~$0.40 por millón de requests
- Artifact Registry: ~$0.10 por GB al mes
- Datos de salida: ~$0.12 por GB

Con tráfico típico de una aplicación admin, el costo mensual debería ser menor a $10 USD.

## Siguiente paso

Una vez configurado todo, tu aplicación se desplegará automáticamente cada vez que hagas push a la rama principal.
