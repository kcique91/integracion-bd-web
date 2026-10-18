import { describe, it, expect, beforeEach } from 'vitest'
import { renderHook, act } from '@testing-library/react'
import { CarritoProvider } from '../context/CarritoContext'
import { useCarrito } from '../context/useCarrito'

// Monta el carrito dentro de su Provider para poder probar sus funciones
function renderizarCarrito() {
  return renderHook(() => useCarrito(), { wrapper: CarritoProvider })
}

describe('CarritoContext (Parte A: carrito de compras)', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('agrega un producto y actualiza el total de unidades', () => {
    const { result } = renderizarCarrito()
    let mensaje

    act(() => {
      mensaje = result.current.agregarAlCarrito('CL001', 2)
    })

    expect(mensaje).toBe('Producto agregado al carrito')
    expect(result.current.carrito).toEqual([{ codigo: 'CL001', cantidad: 2 }])
    expect(result.current.totalUnidades).toBe(2)
  })

  it('no agrega más unidades que el stock disponible', () => {
    const { result } = renderizarCarrito()
    let mensaje

    act(() => {
      mensaje = result.current.agregarAlCarrito('RG002', 13) // stock de RG002: 12
    })

    expect(mensaje).toContain('No hay suficiente stock')
    expect(result.current.carrito).toEqual([])
  })
})