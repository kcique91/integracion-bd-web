import { describe, it, expect, vi } from 'vitest'
import { validarUsuario } from '../utils/validacionesUsuario'

// Datos que pasan todas las validaciones (base para cada prueba)
const datosValidos = {
  run: '190110222',
  nombre: 'Daniel',
  apellidos: 'Soto',
  correo: 'daniel@gmail.com',
  password: 'abcd1234',
  tipoUsuario: 'Cliente',
  region: 'Región Metropolitana',
  comuna: 'Santiago',
  direccion: 'Calle Falsa 123',
}

describe('validarUsuario (formulario de usuarios del admin)', () => {
  it('devuelve un objeto vacío cuando todos los datos son válidos', () => {
    const errores = validarUsuario(datosValidos)

    expect(errores).toEqual({})
  })

  it('rechaza un correo con dominio no permitido', () => {
    const errores = validarUsuario({ ...datosValidos, correo: 'hacker@hotmail.com' })

    expect(errores.correo).toContain('@gmail.com')
  })

  it('usa la función validarRun que se le entrega (mock) para revisar el RUN', () => {
    const validarRunFalso = vi.fn(() => false)

    const errores = validarUsuario(datosValidos, [], false, validarRunFalso)

    expect(validarRunFalso).toHaveBeenCalledWith('190110222')
    expect(errores.run).toContain('RUN inválido')
  })
})