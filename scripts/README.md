# Scripts de Automatización - Documentación

## 📋 Descripción General

Este directorio contiene scripts para automatizar el proceso de testing, commit y despliegue del proyecto. Los scripts están disponibles tanto en Bash (para WSL/Git Bash) como en PowerShell (para Windows nativo).

## 🚀 Scripts Disponibles

### 1. Script Principal: `test-and-deploy`

**Archivos:**
- `test-and-deploy.sh` (Bash)
- `test-and-deploy.ps1` (PowerShell)

**Funcionalidades:**
- ✅ Verifica que estás en un repositorio Git
- ✅ Instala dependencias si es necesario
- ✅ Ejecuta linting con auto-fix
- ✅ Ejecuta todas las pruebas
- ✅ Hace commit automático con timestamp
- ✅ Hace push a la rama principal
- ✅ Muestra resumen detallado
- ✅ Maneja errores graciosamente

### 2. Script Rápido: `quick-deploy`

**Archivos:**
- `quick-deploy.sh` (Bash)
- `quick-deploy.ps1` (PowerShell)

**Funcionalidades:**
- ✅ Versión simplificada para uso diario
- ✅ Ejecuta pruebas rápidamente
- ✅ Hace commit y push automático
- ✅ Menos output, más velocidad

## 🛠️ Instalación y Configuración

### Opción 1: Bash (WSL/Git Bash)

```bash
# Hacer los scripts ejecutables
chmod +x scripts/test-and-deploy.sh
chmod +x scripts/quick-deploy.sh

# Opcional: Crear alias globales
echo 'alias deploy="./scripts/test-and-deploy.sh"' >> ~/.bashrc
echo 'alias quickdeploy="./scripts/quick-deploy.sh"' >> ~/.bashrc
source ~/.bashrc
```

### Opción 2: PowerShell (Windows)

```powershell
# Habilitar ejecución de scripts (ejecutar como administrador)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Opcional: Crear alias en tu perfil de PowerShell
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
Add-Content $PROFILE 'function deploy { .\scripts\test-and-deploy.ps1 @args }'
Add-Content $PROFILE 'function quickdeploy { .\scripts\quick-deploy.ps1 @args }'
```

## 🎯 Uso de los Scripts

### Script Principal (`test-and-deploy`)

#### Bash:
```bash
# Modo interactivo (permite personalizar mensaje de commit)
./scripts/test-and-deploy.sh

# Modo automático (sin prompts)
./scripts/test-and-deploy.sh --auto

# Con alias (después de configurar)
deploy
deploy --auto
```

#### PowerShell:
```powershell
# Modo interactivo
.\scripts\test-and-deploy.ps1

# Modo automático
.\scripts\test-and-deploy.ps1 -Auto

# Especificar rama y prefijo personalizado
.\scripts\test-and-deploy.ps1 -Branch "develop" -CommitPrefix "feat: new feature"

# Con alias (después de configurar)
deploy
deploy -Auto
```

### Script Rápido (`quick-deploy`)

#### Bash:
```bash
# Modo interactivo
./scripts/quick-deploy.sh

# Modo automático
./scripts/quick-deploy.sh --auto

# Con alias
quickdeploy
quickdeploy --auto
```

#### PowerShell:
```powershell
# Modo interactivo
.\scripts\quick-deploy.ps1

# Modo automático
.\scripts\quick-deploy.ps1 -Auto

# Con mensaje personalizado
.\scripts\quick-deploy.ps1 -Message "fix: correción crítica"

# Con alias
quickdeploy
quickdeploy -Auto
```

## 📊 Flujo de Trabajo

### 1. Desarrollo Normal
```bash
# Hacer cambios en tu código
# ...

# Ejecutar script rápido
./scripts/quick-deploy.sh

# O con alias
quickdeploy
```

### 2. Deployment Completo
```bash
# Para deployments importantes
./scripts/test-and-deploy.sh

# O con alias
deploy
```

### 3. Modo Automático (CI/CD local)
```bash
# Para automación completa
./scripts/test-and-deploy.sh --auto

# O con alias
deploy --auto
```

## 🔧 Personalización

### Cambiar Rama por Defecto
```bash
# En test-and-deploy.sh
BRANCH="develop"  # Cambiar de "main" a "develop"
```

```powershell
# En test-and-deploy.ps1
param(
    [string]$Branch = "develop"  # Cambiar de "main" a "develop"
)
```

### Cambiar Prefijo de Commit
```bash
# En test-and-deploy.sh
COMMIT_MESSAGE_PREFIX="feat: automated deploy"
```

```powershell
# En test-and-deploy.ps1
param(
    [string]$CommitPrefix = "feat: automated deploy"
)
```

## 🐛 Solución de Problemas

### Error: "No se pueden ejecutar scripts"
```powershell
# Ejecutar como administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Command not found"
```bash
# Hacer el script ejecutable
chmod +x scripts/test-and-deploy.sh
```

### Error: "npm command not found"
```bash
# Verificar que Node.js está instalado
node --version
npm --version
```

### Error: "Not a git repository"
```bash
# Verificar que estás en la raíz del proyecto
pwd
ls -la .git
```

## 🔍 Logs y Debugging

Los scripts muestran información detallada sobre cada paso:

- 🟦 **[INFO]** - Información general
- 🟩 **[SUCCESS]** - Operación exitosa
- 🟨 **[WARNING]** - Advertencia
- 🟥 **[ERROR]** - Error que requiere atención

### Ejemplo de Output:
```
============================================
  🚀 AUTOMATED TEST & DEPLOY PIPELINE
============================================
[INFO] Verificando dependencias...
[INFO] Dependencias ya instaladas
[INFO] Ejecutando linting...
[SUCCESS] ✅ Linting completado
[INFO] Ejecutando pruebas...
[SUCCESS] ✅ Todas las pruebas pasaron exitosamente
[INFO] Preparando commit...
[SUCCESS] ✅ Commit realizado exitosamente
[INFO] Haciendo push a la rama main...
[SUCCESS] ✅ Push realizado exitosamente
[INFO] El pipeline CI/CD se ejecutará automáticamente en GitHub Actions
============================================
  ✅ PIPELINE COMPLETADO EXITOSAMENTE
============================================
```

## 🔗 Integración con GitHub Actions

Estos scripts son complementarios al pipeline CI/CD configurado en `.github/workflows/deploy.yml`. 

**Flujo completo:**
1. **Local**: Ejecutas el script → Pruebas pasan → Push a GitHub
2. **GitHub Actions**: Se activa automáticamente → Build → Test → Deploy a Cloud Run

## 💡 Consejos de Uso

1. **Usa `quick-deploy` para cambios menores** y iteraciones rápidas
2. **Usa `test-and-deploy` para releases importantes** y cuando quieras ver todo el proceso
3. **Usa el modo `--auto`** para scripts y automación
4. **Configura alias** para acceso rápido desde cualquier lugar del proyecto
5. **Revisa siempre el output** para asegurarte de que todo funciona correctamente

## 🚀 Próximos Pasos

1. Ejecutar el script por primera vez:
   ```bash
   ./scripts/test-and-deploy.sh
   ```

2. Configurar alias para uso diario:
   ```bash
   # Bash
   echo 'alias deploy="./scripts/test-and-deploy.sh"' >> ~/.bashrc
   
   # PowerShell
   Add-Content $PROFILE 'function deploy { .\scripts\test-and-deploy.ps1 @args }'
   ```

3. Usar en tu flujo de trabajo diario:
   ```bash
   # Hacer cambios
   # ...
   
   # Ejecutar pipeline
   deploy
   ```

¡Listo! Ahora tienes un pipeline de automatización completo que te ahorrará mucho tiempo en el desarrollo diario. 🎉
