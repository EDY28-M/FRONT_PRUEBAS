# 🚀 Demo: Scripts de Automatización

## Configuración Inicial (Solo una vez)

### Opción 1: Usar npm scripts
```bash
# Para sistemas Unix/Linux/macOS/WSL
npm run setup

# Para Windows (PowerShell)
npm run setup:windows
```

### Opción 2: Ejecutar directamente
```bash
# Bash/WSL
./scripts/setup.sh

# PowerShell
.\scripts\setup.ps1
```

## Uso Diario

### Script Rápido (Recomendado para uso diario)
```bash
# Usando npm scripts
npm run quick              # Bash/WSL
npm run quick:windows      # PowerShell

# Modo automático (sin prompts)
npm run quick:auto         # Bash/WSL
npm run quick:auto:windows # PowerShell

# Ejecutar directamente
./scripts/quick-deploy.sh        # Bash/WSL
.\scripts\quick-deploy.ps1       # PowerShell
```

### Script Completo (Para deployments importantes)
```bash
# Usando npm scripts
npm run deploy              # Bash/WSL
npm run deploy:windows      # PowerShell

# Modo automático
npm run deploy:auto         # Bash/WSL
npm run deploy:auto:windows # PowerShell

# Ejecutar directamente
./scripts/test-and-deploy.sh    # Bash/WSL
.\scripts\test-and-deploy.ps1   # PowerShell
```

## Ejemplos Prácticos

### Ejemplo 1: Desarrollo Normal
```bash
# 1. Haces cambios en tu código
echo "console.log('Nueva funcionalidad')" >> src/App.tsx

# 2. Ejecutas el script rápido
npm run quick

# 3. ¡Listo! Tu código se despliega automáticamente
```

### Ejemplo 2: Release Importante
```bash
# 1. Terminas una feature importante
git add .
git commit -m "feat: nueva funcionalidad completa"

# 2. Ejecutas el script completo
npm run deploy

# 3. Revisas el progreso en GitHub Actions
```

### Ejemplo 3: Automatización Completa
```bash
# Para usar en scripts de CI/CD local
npm run deploy:auto

# O para pushes rápidos sin interacción
npm run quick:auto
```

## Output Esperado

### Script Rápido:
```
🚀 Ejecutando pipeline rápido...
🧪 Ejecutando pruebas...
✅ Test Suites: 3 passed, 3 total
✅ Tests:       11 passed, 11 total
🔍 Ejecutando linting...
📝 Haciendo commit...
🚀 Haciendo push...
✅ ¡Pipeline completado exitosamente!
🌐 Revisa el progreso en GitHub Actions
```

### Script Completo:
```
=============================================
  🚀 AUTOMATED TEST & DEPLOY PIPELINE
=============================================
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
=============================================
  ✅ PIPELINE COMPLETADO EXITOSAMENTE
=============================================
• Pruebas ejecutadas: ✅
• Linting ejecutado: ✅
• Cambios commiteados: ✅
• Push realizado: ✅
• CI/CD activado: ✅

🌐 Revisa el progreso en:
   GitHub Actions: https://github.com/tu-usuario/tu-repo/actions
   Cloud Run: https://console.cloud.google.com/run
=============================================
```

## Ventajas de los Scripts

✅ **Consistencia**: Siempre ejecuta las mismas verificaciones
✅ **Seguridad**: Solo hace push si las pruebas pasan
✅ **Rapidez**: Automatiza todo el proceso manual
✅ **Flexibilidad**: Modo interactivo y automático
✅ **Multiplataforma**: Funciona en Windows, Linux, macOS
✅ **Integración**: Se conecta con GitHub Actions automáticamente

## Troubleshooting

### Error: "Scripts no ejecutables"
```bash
chmod +x scripts/*.sh
```

### Error: "Política de ejecución"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Comando no encontrado"
```bash
# Verificar que estás en la raíz del proyecto
ls package.json

# Verificar que los scripts existen
ls scripts/
```

## Próximos Pasos

1. **Configura una vez**: `npm run setup`
2. **Usa diariamente**: `npm run quick`
3. **Para releases**: `npm run deploy`
4. **Automatiza todo**: `npm run deploy:auto`

¡Ahora tienes un pipeline de automatización completo que te ahorrará horas de trabajo manual! 🎉
