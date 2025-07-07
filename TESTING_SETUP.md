# Configuración de Pruebas Automatizadas

Este proyecto necesita pruebas automatizadas. Vamos a implementar:

## 1. Instalación de dependencias de testing

```bash
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
```

## 2. Configuración de Vitest

Crear archivo `vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
  },
})
```

## 3. Scripts de pruebas a agregar en package.json

```json
{
  "scripts": {
    "test": "vitest",
    "test:ci": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

## 4. Ejemplos de pruebas

### Pruebas de componentes
### Pruebas de servicios
### Pruebas de utilidades
### Pruebas de integración

## 5. Cobertura de código

Configurar cobertura mínima requerida.
