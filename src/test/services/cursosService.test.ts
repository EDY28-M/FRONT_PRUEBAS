import { describe, expect, it } from 'vitest'
import { cursosApi } from '../../services/cursosService'

describe('cursosApi', () => {
  it('should have getAll method', () => {
    expect(typeof cursosApi.getAll).toBe('function')
  })

  it('should have getById method', () => {
    expect(typeof cursosApi.getById).toBe('function')
  })

  it('should have create method', () => {
    expect(typeof cursosApi.create).toBe('function')
  })

  it('should have update method', () => {
    expect(typeof cursosApi.update).toBe('function')
  })

  it('should have delete method', () => {
    expect(typeof cursosApi.delete).toBe('function')
  })
})
