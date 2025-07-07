# Dockerfile multi-stage para optimizar el build
# Etapa 1: Build
FROM node:18-alpine AS builder

# Instalar dependencias necesarias
RUN apk add --no-cache git

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración
COPY package*.json ./
COPY tsconfig*.json ./
COPY vite.config.ts ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Instalar dependencias (incluyendo devDependencies para el build)
RUN npm ci && npm cache clean --force

# Copiar código fuente
COPY . .

# Build de la aplicación
RUN npm run build

# Etapa 2: Servidor de producción
FROM nginx:alpine AS production

# Instalar curl para health check
RUN apk add --no-cache curl

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar archivos build desde la etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Crear usuario no root para seguridad (grupo nginx ya existe)
RUN adduser -S -u 1001 -G nginx appuser

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
