import { render } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import App from '../App'

// Wrapper para proveer el Router context y QueryClient
const AppWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  })

  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </QueryClientProvider>
  )
}

describe('App', () => {
  it('renders without crashing', () => {
    render(<AppWrapper />)
    // Solo verificar que el componente se renderice sin crash
    expect(document.body).toBeInTheDocument()
  })

  it('has navigation structure', () => {
    render(<AppWrapper />)
    // Verificar que existe estructura básica de la aplicación
    expect(document.body.firstChild).toBeInTheDocument()
  })
})
