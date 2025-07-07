/**
 * Configuración centralizada de URLs de la API
 */
export const API_CONFIG = {
  // URL base principal
  BASE_URL: import.meta.env.VITE_API_URL || 'https://34.60.233.211/api',
  
  // URLs de respaldo
  BACKUP_HTTPS: import.meta.env.VITE_BACKEND_HTTPS || 'https://34.60.233.211/api',
  BACKUP_HTTP: import.meta.env.VITE_BACKEND_HTTP || 'https://34.60.233.211/api',
  
  // URLs auxiliares
  SWAGGER_URL: import.meta.env.VITE_SWAGGER_URL || 'https://34.60.233.211/swagger',
  FRONTEND_URL: import.meta.env.VITE_FRONTEND_URL || 'http://localhost:5173',
  
  // Configuración de desarrollo
  DEV_MODE: import.meta.env.VITE_DEV_MODE === 'true',
  ENABLE_DEVTOOLS: import.meta.env.VITE_ENABLE_DEVTOOLS === 'true',
  
  // Timeout y configuraciones
  TIMEOUT: 10000,
  RETRY_ATTEMPTS: 3,
} as const

/**
 * Obtiene la URL de la API con fallback
 */
export const getApiUrl = (): string => {
  const urls = [
    API_CONFIG.BASE_URL,
    API_CONFIG.BACKUP_HTTPS,
    API_CONFIG.BACKUP_HTTP,
  ].filter(Boolean)
  
  return urls[0] || 'https://34.60.233.211/api'
}

/**
 * Logs de configuración para debugging
 */
if (API_CONFIG.DEV_MODE) {
  console.group('🔧 API Configuration')
  console.log('Base URL:', API_CONFIG.BASE_URL)
  console.log('Swagger URL:', API_CONFIG.SWAGGER_URL)
  console.log('Frontend URL:', API_CONFIG.FRONTEND_URL)
  console.log('Dev Mode:', API_CONFIG.DEV_MODE)
  console.groupEnd()
}
