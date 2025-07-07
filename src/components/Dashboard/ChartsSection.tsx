import { motion } from 'framer-motion'
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { Docente, Curso } from '../../types'

interface ChartsSectionProps {
  docentes?: Docente[]
  cursos?: Curso[]
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4']

const ChartsSection: React.FC<ChartsSectionProps> = ({ docentes = [], cursos = [] }) => {
  // Datos para gráfico de cursos por ciclo
  const cursosPorCiclo = Array.from({ length: 10 }, (_, i) => {
    const ciclo = i + 1
    const count = cursos.filter(curso => curso.ciclo === ciclo).length
    return {
      ciclo: `Ciclo ${ciclo}`,
      cantidad: count,
    }
  }).filter(item => item.cantidad > 0)

  // Datos para gráfico de docentes por profesión
  const docentesPorProfesion = docentes.reduce((acc: Record<string, number>, docente) => {
    const profesion = docente.profesion || 'Sin especificar'
    acc[profesion] = (acc[profesion] || 0) + 1
    return acc
  }, {})

  const profesionData = Object.entries(docentesPorProfesion).map(([profesion, cantidad]) => ({
    profesion,
    cantidad,
  }))

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Resumen de Créditos - Movido arriba para mejor UX móvil */}
      <motion.div
        className="card p-4 sm:p-6"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <h3 className="text-base sm:text-lg font-medium text-gray-900 mb-3 sm:mb-4">Resumen Académico</h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">
          <div className="text-center p-3 sm:p-4 bg-blue-50 rounded-lg">
            <div className="text-xl sm:text-2xl font-bold text-blue-600">
              {cursos.reduce((sum, curso) => sum + curso.creditos, 0)}
            </div>
            <div className="text-xs sm:text-sm text-blue-600 mt-1">Total Créditos</div>
          </div>
          <div className="text-center p-3 sm:p-4 bg-green-50 rounded-lg">
            <div className="text-xl sm:text-2xl font-bold text-green-600">
              {cursos.reduce((sum, curso) => sum + curso.horasSemanal, 0)}
            </div>
            <div className="text-xs sm:text-sm text-green-600 mt-1">Horas Semanales</div>
          </div>
          <div className="text-center p-3 sm:p-4 bg-purple-50 rounded-lg">
            <div className="text-xl sm:text-2xl font-bold text-purple-600">
              {Math.round((cursos.reduce((sum, curso) => sum + curso.creditos, 0) / cursos.length) || 0)}
            </div>
            <div className="text-xs sm:text-sm text-purple-600 mt-1">Promedio Créditos</div>
          </div>
        </div>
      </motion.div>

      {/* Gráficos principales - Layout responsivo */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-4 sm:gap-6">
        {/* Cursos por Ciclo */}
        <motion.div
          className="card p-4 sm:p-6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <h3 className="text-base sm:text-lg font-medium text-gray-900 mb-3 sm:mb-4">
            Distribución por Ciclo
          </h3>
          <div className="h-64 sm:h-72 lg:h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart 
                data={cursosPorCiclo}
                margin={{ 
                  top: 5, 
                  right: 5, 
                  left: 5, 
                  bottom: 5 
                }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis 
                  dataKey="ciclo" 
                  fontSize={12}
                  tick={{ fontSize: 10 }}
                  className="text-xs sm:text-sm"
                />
                <YAxis 
                  fontSize={12}
                  tick={{ fontSize: 10 }}
                  className="text-xs sm:text-sm"
                />
                <Tooltip 
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                    fontSize: '14px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                  }}
                />
                <Bar 
                  dataKey="cantidad" 
                  fill="#3B82F6" 
                  radius={[4, 4, 0, 0]}
                  maxBarSize={60}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Docentes por Profesión */}
        <motion.div
          className="card p-4 sm:p-6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <h3 className="text-base sm:text-lg font-medium text-gray-900 mb-3 sm:mb-4">
            Docentes por Profesión
          </h3>
          <div className="h-64 sm:h-72 lg:h-80">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={profesionData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ profesion, percent }) => {
                    const displayText = profesion.length > 15 
                      ? `${profesion.substring(0, 12)}...` 
                      : profesion;
                    return `${displayText} ${(percent * 100).toFixed(0)}%`;
                  }}
                  outerRadius="75%"
                  innerRadius="25%"
                  fill="#8884d8"
                  dataKey="cantidad"
                  fontSize={10}
                >
                  {profesionData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip 
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #e5e7eb',
                    borderRadius: '8px',
                    fontSize: '14px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </motion.div>
      </div>

      {/* Tabla de datos móvil-friendly */}
      {(cursosPorCiclo.length > 0 || profesionData.length > 0) && (
        <motion.div
          className="card p-4 sm:p-6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <h3 className="text-base sm:text-lg font-medium text-gray-900 mb-3 sm:mb-4">
            Datos Detallados
          </h3>
          
          {/* Vista móvil - Cards */}
          <div className="block sm:hidden space-y-3">
            {cursosPorCiclo.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Cursos por Ciclo</h4>
                <div className="grid grid-cols-2 gap-2">
                  {cursosPorCiclo.map((item) => (
                    <div key={item.ciclo} className="bg-gray-50 p-3 rounded-lg">
                      <div className="text-sm font-medium text-gray-900">{item.ciclo}</div>
                      <div className="text-lg font-bold text-blue-600">{item.cantidad}</div>
                      <div className="text-xs text-gray-500">cursos</div>
                    </div>
                  ))}
                </div>
              </div>
            )}
            
            {profesionData.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Docentes por Profesión</h4>
                <div className="space-y-2">
                  {profesionData.map((item, index) => (
                    <div key={item.profesion} className="flex items-center justify-between bg-gray-50 p-3 rounded-lg">
                      <div className="flex items-center">
                        <div 
                          className="w-3 h-3 rounded-full mr-2"
                          style={{ backgroundColor: COLORS[index % COLORS.length] }}
                        ></div>
                        <span className="text-sm text-gray-900 truncate">{item.profesion}</span>
                      </div>
                      <span className="text-sm font-bold text-gray-900">{item.cantidad}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Vista desktop - Tabla */}
          <div className="hidden sm:block overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Categoría
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Descripción
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cantidad
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {cursosPorCiclo.map((item) => (
                  <tr key={item.ciclo} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      Cursos
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {item.ciclo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.cantidad}
                    </td>
                  </tr>
                ))}
                {profesionData.map((item) => (
                  <tr key={item.profesion} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      Docentes
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {item.profesion}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.cantidad}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>
      )}
    </div>
  )
}

export default ChartsSection
