import axios, { AxiosResponse } from 'axios'
import { getApiUrl, API_CONFIG } from './config'

// Usar la configuración centralizada
const api = axios.create({
  baseURL: getApiUrl(),
  timeout: API_CONFIG.TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor para logging
api.interceptors.request.use(
  (config) => {
    console.log(`🚀 ${config.method?.toUpperCase()} ${config.url}`)
    console.log('📡 Base URL:', config.baseURL)
    return config
  },
  (error) => {
    console.error('❌ Request error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor para manejo de errores
api.interceptors.response.use(
  (response: AxiosResponse) => {
    console.log(`✅ ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('❌ Response error:', error.response?.data || error.message)
    console.error('🔗 Failed URL:', error.config?.url)
    console.error('🌐 Base URL:', error.config?.baseURL)
    
    if (error.response?.status === 401) {
      // Handle unauthorized access
      console.warn('🔐 Unauthorized access, redirecting to login')
      window.location.href = '/login'
    }
    
    return Promise.reject(error)
  }
)

export default api
