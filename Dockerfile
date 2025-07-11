# Dockerfile para producción Vite + Nginx en Render
# Build stage
FROM node:20-alpine as build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Cloud Run sets $PORT, así que lo usamos en Nginx
ENV PORT=8080
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
