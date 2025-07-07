export interface Docente {
  id: number
  apellidos: string
  nombres: string
  profesion?: string
  fechaNacimiento?: string
  correo?: string
  cursos: CursoSimple[]
}

export interface DocenteCreate {
  apellidos: string
  nombres: string
  profesion?: string
  fechaNacimiento?: string
  correo?: string
}

export interface DocenteUpdate {
  apellidos: string
  nombres: string
  profesion?: string
  fechaNacimiento?: string
  correo?: string
}

export interface DocenteSimple {
  id: number
  apellidos: string
  nombres: string
  profesion?: string
}

export interface Curso {
  id: number
  nombreCurso: string
  creditos: number
  horasSemanal: number
  ciclo: number
  idDocente?: number
  docente?: DocenteSimple
}

export interface CursoCreate {
  nombreCurso: string
  creditos: number
  horasSemanal: number
  ciclo: number
  idDocente?: number
}

export interface CursoUpdate {
  nombreCurso: string
  creditos: number
  horasSemanal: number
  ciclo: number
  idDocente?: number
}

export interface CursoSimple {
  id: number
  nombreCurso: string
  creditos: number
  horasSemanal: number
  ciclo: number
}

export interface ApiResponse<T> {
  data: T
  message?: string
  success: boolean
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  pageSize: number
  totalPages: number
}

export interface ChartData {
  name: string
  value: number
  color?: string
}

export interface DashboardStats {
  totalDocentes: number
  totalCursos: number
  totalCreditos: number
  promedioHorasSemanal: number
  cursosPorCiclo: ChartData[]
  docentesPorProfesion: ChartData[]
}
