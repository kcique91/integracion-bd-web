import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import TarjetaProducto from '../components/TarjetaProducto'
import { formatearPrecio } from '../utils/formatearPrecio'

// Mock del carrito: reemplaza useCarrito por una versión falsa que podemos espiar
const agregarAlCarritoMock = vi.fn()
vi.mock('../context/useCarrito', () => ({
  useCarrito: () => ({ agregarAlCarrito: agregarAlCarritoMock }),
}))

const producto = {
  codigo: 'CL001',
  categoria: 'Cilindros de Gas',
  nombre: 'Cilindro GLP 5 kg',
  precioResidencial: 6500,
  imagen: 'cilindro.jpg',
}

// La tarjeta usa <Link>, por eso se renderiza dentro de un MemoryRouter
function mostrarTarjeta() {
  return render(
    <MemoryRouter>
      <TarjetaProducto producto={producto} />
    </MemoryRouter>,
  )
}

describe('TarjetaProducto (Parte A: catálogo de productos)', () => {
  beforeEach(() => {
    agregarAlCarritoMock.mockReset()
    // alert no existe de verdad en jsdom: se reemplaza por una función falsa
    vi.spyOn(window, 'alert').mockImplementation(() => {})
  })

  it('muestra el nombre, el precio y la imagen del producto', () => {
    mostrarTarjeta()

    expect(screen.getByText('Cilindro GLP 5 kg')).toBeInTheDocument()
    expect(screen.getByText(formatearPrecio(6500))).toBeInTheDocument()
    expect(screen.getByAltText('Cilindro GLP 5 kg')).toBeInTheDocument()
  })

  it('al presionar "Añadir" agrega 1 unidad al carrito y avisa el resultado', async () => {
    agregarAlCarritoMock.mockReturnValue('Producto agregado al carrito')
    const usuario = userEvent.setup()
    mostrarTarjeta()

    await usuario.click(screen.getByRole('button', { name: /añadir/i }))

    expect(agregarAlCarritoMock).toHaveBeenCalledWith('CL001', 1)
    expect(window.alert).toHaveBeenCalledWith('Producto agregado al carrito')
  })
})