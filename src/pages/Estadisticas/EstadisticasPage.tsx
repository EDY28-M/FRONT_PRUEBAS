import { motion } from 'framer-motion'
import { useQuery } from '@tanstack/react-query'
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts'
import { docentesApi } from '../../services/docentesService'
import { cursosApi } from '../../services/cursosService'

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4', '#EC4899', '#14B8A6']

const EstadisticasPage = () => {
  const { data: docentes, isLoading: loadingDocentes } = useQuery({
    queryKey: ['docentes'],
    queryFn: docentesApi.getAll,
  })

  const { data: cursos, isLoading: loadingCursos } = useQuery({
    queryKey: ['cursos'],
    queryFn: cursosApi.getAll,
  })

  // Estadísticas de cursos por ciclo
  const cursosPorCiclo = Array.from({ length: 10 }, (_, i) => {
    const ciclo = i + 1
    const count = cursos?.filter(curso => curso.ciclo === ciclo).length || 0
    return {
      ciclo: `Ciclo ${ciclo}`,
      cantidad: count,
      creditos: cursos?.filter(curso => curso.ciclo === ciclo).reduce((sum, curso) => sum + curso.creditos, 0) || 0,
    }
  }).filter(item => item.cantidad > 0)

  // Estadísticas de docentes por profesión
  const docentesPorProfesion = docentes?.reduce((acc: Record<string, number>, docente) => {
    const profesion = docente.profesion || 'Sin especificar'
    acc[profesion] = (acc[profesion] || 0) + 1
    return acc
  }, {}) || {}

  const profesionData = Object.entries(docentesPorProfesion).map(([profesion, cantidad]) => ({
    profesion,
    cantidad,
  }))

  // Distribución de créditos
  const creditosDistribution = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(credito => ({
    creditos: credito,
    cantidad: cursos?.filter(curso => curso.creditos === credito).length || 0,
  })).filter(item => item.cantidad > 0)

  // Carga horaria por ciclo
  const cargaHoraria = cursosPorCiclo.map(item => ({
    ciclo: item.ciclo,
    horas: cursos?.filter(curso => curso.ciclo === parseInt(item.ciclo.split(' ')[1]))
      .reduce((sum, curso) => sum + curso.horasSemanal, 0) || 0,
  }))

  const isLoading = loadingDocentes || loadingCursos

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="md:flex md:items-center md:justify-between"
      >
        <div className="min-w-0 flex-1">
          <h2 className="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight">
            Estadísticas y Reportes
          </h2>
          <p className="mt-1 text-sm text-gray-500">
            Análisis detallado del sistema académico
          </p>
        </div>
      </motion.div>

      {/* Resumen General */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
      >
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-blue-600">{docentes?.length || 0}</div>
          <div className="text-sm text-gray-600">Total Docentes</div>
        </div>
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-green-600">{cursos?.length || 0}</div>
          <div className="text-sm text-gray-600">Total Cursos</div>
        </div>
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-purple-600">
            {cursos?.reduce((sum, curso) => sum + curso.creditos, 0) || 0}
          </div>
          <div className="text-sm text-gray-600">Total Créditos</div>
        </div>
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-orange-600">
            {cursos?.reduce((sum, curso) => sum + curso.horasSemanal, 0) || 0}
          </div>
          <div className="text-sm text-gray-600">Horas Semanales</div>
        </div>
      </motion.div>

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Cursos por Ciclo */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
          className="card p-6"
        >
          <h3 className="text-lg font-medium text-gray-900 mb-4">Cursos por Ciclo</h3>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={cursosPorCiclo}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="ciclo" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="cantidad" fill="#3B82F6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Docentes por Profesión */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.3 }}
          className="card p-6"
        >
          <h3 className="text-lg font-medium text-gray-900 mb-4">Docentes por Profesión</h3>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={profesionData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ profesion, percent }) => `${profesion} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="cantidad"
                >
                  {profesionData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Distribución de Créditos */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="card p-6"
        >
          <h3 className="text-lg font-medium text-gray-900 mb-4">Distribución de Créditos</h3>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={creditosDistribution}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="creditos" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="cantidad" fill="#10B981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Carga Horaria por Ciclo */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="card p-6"
        >
          <h3 className="text-lg font-medium text-gray-900 mb-4">Carga Horaria por Ciclo</h3>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={cargaHoraria}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="ciclo" />
                <YAxis />
                <Tooltip />
                <Line 
                  type="monotone" 
                  dataKey="horas" 
                  stroke="#8B5CF6" 
                  strokeWidth={3}
                  dot={{ fill: '#8B5CF6', strokeWidth: 2, r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </motion.div>
      </div>

      {/* Tabla de Detalles */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="card"
      >
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">Resumen por Ciclo</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="table">
            <thead className="table-header">
              <tr>
                <th className="table-header-cell">Ciclo</th>
                <th className="table-header-cell">Cursos</th>
                <th className="table-header-cell">Créditos Totales</th>
                <th className="table-header-cell">Horas Semanales</th>
                <th className="table-header-cell">Promedio Créditos</th>
                <th className="table-header-cell">Promedio Horas</th>
              </tr>
            </thead>
            <tbody className="table-body">
              {cursosPorCiclo.map((item, index) => {
                const cicloNum = parseInt(item.ciclo.split(' ')[1])
                const cursosDelCiclo = cursos?.filter(curso => curso.ciclo === cicloNum) || []
                const horasSemanales = cursosDelCiclo.reduce((sum, curso) => sum + curso.horasSemanal, 0)
                const promedioCreditos = cursosDelCiclo.length > 0 ? (item.creditos / cursosDelCiclo.length).toFixed(1) : '0'
                const promedioHoras = cursosDelCiclo.length > 0 ? (horasSemanales / cursosDelCiclo.length).toFixed(1) : '0'

                return (
                  <motion.tr
                    key={item.ciclo}
                    className="table-row"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05 }}
                  >
                    <td className="table-cell font-medium">{item.ciclo}</td>
                    <td className="table-cell">{item.cantidad}</td>
                    <td className="table-cell">{item.creditos}</td>
                    <td className="table-cell">{horasSemanales}</td>
                    <td className="table-cell">{promedioCreditos}</td>
                    <td className="table-cell">{promedioHoras}</td>
                  </motion.tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </motion.div>
    </div>
  )
}

export default EstadisticasPage
