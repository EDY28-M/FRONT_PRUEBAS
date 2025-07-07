# Script para corregir permisos del service account de GitHub Actions

# Verificar que estés logueado en gcloud
Write-Host "Verificando autenticación en gcloud..." -ForegroundColor Yellow
gcloud auth list

# Configurar el proyecto
$PROJECT_ID = "ascendant-altar-457900-v4"
$SA_EMAIL = "github-actions-new@$PROJECT_ID.iam.gserviceaccount.com"

Write-Host "Configurando permisos para: $SA_EMAIL" -ForegroundColor Green

# Roles necesarios para Cloud Run deployment
$roles = @(
    "roles/cloudbuild.builds.builder",
    "roles/run.admin",
    "roles/run.developer",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/compute.admin"
)

# Agregar cada rol
foreach ($role in $roles) {
    Write-Host "Agregando rol: $role" -ForegroundColor Cyan
    gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="$role"
}

# Verificar permisos
Write-Host "Verificando permisos del service account..." -ForegroundColor Yellow
gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$SA_EMAIL"

Write-Host "¡Permisos actualizados!" -ForegroundColor Green
Write-Host "Ahora puedes intentar el deployment nuevamente." -ForegroundColor Yellow
