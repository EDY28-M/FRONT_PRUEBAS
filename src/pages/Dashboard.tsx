import { motion } from 'framer-motion'
import { useQuery } from '@tanstack/react-query'
import { 
  UserGroupIcon, 
  AcademicCapIcon, 
  ClockIcon,
  TrophyIcon 
} from '@heroicons/react/24/outline'
import { docentesApi } from '../services/docentesService'
import { cursosApi } from '../services/cursosService'
import StatsCard from '../components/Dashboard/StatsCard'
import RecentActivity from '../components/Dashboard/RecentActivity'
import QuickActions from '../components/Dashboard/QuickActions'
import ChartsSection from '../components/Dashboard/ChartsSection'

const Dashboard = () => {
  const { data: docentes, isLoading: loadingDocentes } = useQuery({
    queryKey: ['docentes'],
    queryFn: docentesApi.getAll,
  })

  const { data: cursos, isLoading: loadingCursos } = useQuery({
    queryKey: ['cursos'],
    queryFn: cursosApi.getAll,
  })

  const stats = [
    {
      name: 'Total Docentes',
      value: docentes?.length || 0,
      icon: UserGroupIcon,
      color: 'bg-blue-500',
      change: '+12%',
      changeType: 'positive' as const,
    },
    {
      name: 'Total Cursos',
      value: cursos?.length || 0,
      icon: AcademicCapIcon,
      color: 'bg-green-500',
      change: '+8%',
      changeType: 'positive' as const,
    },
    {
      name: 'Total Créditos',
      value: cursos?.reduce((sum, curso) => sum + curso.creditos, 0) || 0,
      icon: TrophyIcon,
      color: 'bg-purple-500',
      change: '+5%',
      changeType: 'positive' as const,
    },
    {
      name: 'Horas Semanales',
      value: cursos?.reduce((sum, curso) => sum + curso.horasSemanal, 0) || 0,
      icon: ClockIcon,
      color: 'bg-orange-500',
      change: '+15%',
      changeType: 'positive' as const,
    },
  ]

  const isLoading = loadingDocentes || loadingCursos

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="min-w-0 flex-1">
            <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold leading-7 text-gray-900 tracking-tight">
              Dashboard
            </h2>
            <p className="mt-1 text-sm text-gray-500">
              Resumen general del sistema de gestión académica
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-2 sm:gap-3">
            <button
              type="button"
              className="inline-flex items-center justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 transition-colors"
            >
              Exportar Datos
            </button>
            <button
              type="button"
              className="inline-flex items-center justify-center rounded-md bg-primary-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-primary-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600 transition-colors"
            >
              Generar Reporte
            </button>
          </div>
        </div>
      </motion.div>

      {/* Stats Cards */}
      <motion.div
        className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        {stats.map((stat, index) => (
          <motion.div
            key={stat.name}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3, delay: index * 0.1 }}
          >
            <StatsCard {...stat} isLoading={isLoading} />
          </motion.div>
        ))}
      </motion.div>

      {/* Main Content Grid - Stack en móvil, grid en desktop */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4 sm:gap-6">
        {/* Charts Section */}
        <motion.div
          className="xl:col-span-2 order-2 xl:order-1"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <ChartsSection docentes={docentes} cursos={cursos} />
        </motion.div>

        {/* Sidebar Content - Aparece primero en móvil para mejor UX */}
        <motion.div
          className="space-y-4 sm:space-y-6 order-1 xl:order-2"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          {/* Quick Actions */}
          <QuickActions />
          
          {/* Recent Activity */}
          <RecentActivity />
        </motion.div>
      </div>
    </div>
  )
}

export default Dashboard
