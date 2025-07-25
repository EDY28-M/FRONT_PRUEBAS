import { Fragment, useEffect } from 'react'
import { Dialog, Transition } from '@headlessui/react'
import { XMarkIcon } from '@heroicons/react/24/outline'
import { useForm } from 'react-hook-form'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from 'react-toastify'
import { cursosApi } from '../../services/cursosService'
import { Curso, CursoCreate, CursoUpdate, Docente } from '../../types'

interface CursoModalProps {
  isOpen: boolean
  onClose: () => void
  curso?: Curso | null
  mode: 'create' | 'edit' | 'view'
  docentes: Docente[]
}

const CursoModal: React.FC<CursoModalProps> = ({
  isOpen,
  onClose,
  curso,
  mode,
  docentes,
}) => {
  const queryClient = useQueryClient()
  const isViewMode = mode === 'view'
  const isEditMode = mode === 'edit'
  const isCreateMode = mode === 'create'

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setValue,
  } = useForm<CursoCreate | CursoUpdate>()

  useEffect(() => {
    if (isOpen && curso && (isEditMode || isViewMode)) {
      setValue('nombreCurso', curso.nombreCurso)
      setValue('creditos', curso.creditos)
      setValue('horasSemanal', curso.horasSemanal)
      setValue('ciclo', curso.ciclo)
      setValue('idDocente', curso.idDocente || undefined)
    } else if (isOpen && isCreateMode) {
      reset()
    }
  }, [isOpen, curso, mode, setValue, reset, isEditMode, isViewMode, isCreateMode])

  const createMutation = useMutation({
    mutationFn: cursosApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cursos'] })
      toast.success('Curso creado exitosamente')
      onClose()
    },
    onError: (error) => {
      toast.error('Error al crear curso')
      console.error('Error:', error)
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: CursoUpdate }) =>
      cursosApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cursos'] })
      toast.success('Curso actualizado exitosamente')
      onClose()
    },
    onError: (error) => {
      toast.error('Error al actualizar curso')
      console.error('Error:', error)
    },
  })

  const onSubmit = (data: CursoCreate | CursoUpdate) => {
    const formData = {
      ...data,
      idDocente: data.idDocente || undefined,
    }

    if (isCreateMode) {
      createMutation.mutate(formData as CursoCreate)
    } else if (isEditMode && curso) {
      updateMutation.mutate({ id: curso.id, data: formData as CursoUpdate })
    }
  }

  const title = isCreateMode ? 'Nuevo Curso' : isEditMode ? 'Editar Curso' : 'Ver Curso'

  return (
    <Transition.Root show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
        </Transition.Child>

        <div className="fixed inset-0 z-10 w-screen overflow-y-auto">
          <div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              enterTo="opacity-100 translate-y-0 sm:scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 translate-y-0 sm:scale-100"
              leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            >
              <Dialog.Panel className="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
                <div className="absolute right-0 top-0 pr-4 pt-4">
                  <button
                    type="button"
                    className="rounded-md bg-white text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    onClick={onClose}
                  >
                    <span className="sr-only">Cerrar</span>
                    <XMarkIcon className="h-6 w-6" aria-hidden="true" />
                  </button>
                </div>

                <div className="sm:flex sm:items-start">
                  <div className="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left w-full">
                    <Dialog.Title as="h3" className="text-lg font-semibold leading-6 text-gray-900 mb-4">
                      {title}
                    </Dialog.Title>

                    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                      <div>
                        <label className="label">Nombre del Curso *</label>
                        <input
                          type="text"
                          {...register('nombreCurso', { required: 'El nombre del curso es requerido' })}
                          className="input"
                          disabled={isViewMode}
                        />
                        {errors.nombreCurso && (
                          <p className="mt-1 text-sm text-red-600">{errors.nombreCurso.message}</p>
                        )}
                      </div>

                      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div>
                          <label className="label">Créditos *</label>
                          <input
                            type="number"
                            min="1"
                            max="10"
                            {...register('creditos', { 
                              required: 'Los créditos son requeridos',
                              min: { value: 1, message: 'Mínimo 1 crédito' },
                              max: { value: 10, message: 'Máximo 10 créditos' }
                            })}
                            className="input"
                            disabled={isViewMode}
                          />
                          {errors.creditos && (
                            <p className="mt-1 text-sm text-red-600">{errors.creditos.message}</p>
                          )}
                        </div>

                        <div>
                          <label className="label">Horas Semanales *</label>
                          <input
                            type="number"
                            min="1"
                            max="40"
                            {...register('horasSemanal', { 
                              required: 'Las horas semanales son requeridas',
                              min: { value: 1, message: 'Mínimo 1 hora' },
                              max: { value: 40, message: 'Máximo 40 horas' }
                            })}
                            className="input"
                            disabled={isViewMode}
                          />
                          {errors.horasSemanal && (
                            <p className="mt-1 text-sm text-red-600">{errors.horasSemanal.message}</p>
                          )}
                        </div>

                        <div>
                          <label className="label">Ciclo *</label>
                          <select
                            {...register('ciclo', { required: 'El ciclo es requerido' })}
                            className="input"
                            disabled={isViewMode}
                          >
                            <option value="">Seleccionar ciclo</option>
                            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((ciclo) => (
                              <option key={ciclo} value={ciclo}>
                                Ciclo {ciclo}
                              </option>
                            ))}
                          </select>
                          {errors.ciclo && (
                            <p className="mt-1 text-sm text-red-600">{errors.ciclo.message}</p>
                          )}
                        </div>
                      </div>

                      <div>
                        <label className="label">Docente Asignado</label>
                        <select
                          {...register('idDocente')}
                          className="input"
                          disabled={isViewMode}
                        >
                          <option value="">Sin asignar</option>
                          {docentes.map((docente) => (
                            <option key={docente.id} value={docente.id}>
                              {docente.nombres} {docente.apellidos} - {docente.profesion}
                            </option>
                          ))}
                        </select>
                      </div>

                      {!isViewMode && (
                        <div className="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
                          <button
                            type="submit"
                            className="btn btn-primary btn-md w-full sm:ml-3 sm:w-auto"
                            disabled={createMutation.isPending || updateMutation.isPending}
                          >
                            {createMutation.isPending || updateMutation.isPending
                              ? 'Guardando...'
                              : isCreateMode
                              ? 'Crear Curso'
                              : 'Actualizar Curso'}
                          </button>
                          <button
                            type="button"
                            className="btn btn-outline btn-md mt-3 w-full sm:mt-0 sm:w-auto"
                            onClick={onClose}
                          >
                            Cancelar
                          </button>
                        </div>
                      )}
                    </form>
                  </div>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition.Root>
  )
}

export default CursoModal
