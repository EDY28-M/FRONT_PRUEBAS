import { Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout/Layout'
import Dashboard from './pages/Dashboard'
import DocentesPage from './pages/Docentes/DocentesPage'
import CursosPage from './pages/Cursos/CursosPage'
import EstadisticasPage from './pages/Estadisticas/EstadisticasPage'

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/docentes" element={<DocentesPage />} />
        <Route path="/cursos" element={<CursosPage />} />
        <Route path="/estadisticas" element={<EstadisticasPage />} />
      </Routes>
    </Layout>
  )
}

export default App
