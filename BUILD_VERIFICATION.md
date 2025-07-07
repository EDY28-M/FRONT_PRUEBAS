# Verificación del Build Local

Este script verifica que el build funcione correctamente antes del deployment.

## Uso

### Windows PowerShell:
```powershell
.\verify-build.ps1
```

### Linux/macOS:
```bash
chmod +x verify-build.sh
./verify-build.sh
```

## ¿Qué verifica?

1. ✅ **Dependencias**: Verifica que todas las dependencias estén instaladas
2. ✅ **Linting**: Ejecuta ESLint para verificar la calidad del código
3. ✅ **TypeScript**: Verifica que no haya errores de tipado
4. ✅ **Build**: Ejecuta el build de producción
5. ✅ **Assets**: Verifica que los archivos se generen correctamente
6. ✅ **Docker**: (Opcional) Verifica que el build de Docker funcione
7. ✅ **Preview**: Inicia un servidor local para probar el build

## En caso de errores

### Error de dependencias
```bash
npm ci
```

### Error de linting
```bash
npm run lint:fix
```

### Error de build
- Revisa la consola para errores específicos
- Verifica las variables de entorno en `.env`
- Asegúrate de que todas las importaciones sean correctas

### Error de Docker
- Verifica que Docker Desktop esté ejecutándose
- Revisa el Dockerfile para errores de sintaxis
