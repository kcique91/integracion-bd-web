import { Button, Container, Table } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import ImagenProducto from '../components/ImagenProducto'
import { useCarrito } from '../context/useCarrito'
import { buscarProducto } from '../services/productosService'
import { formatearPrecio } from '../utils/formatearPrecio'
import './Carrito.css'

function Carrito() {
  const { carrito, quitarDelCarrito, actualizarCantidad } = useCarrito()

  // Une cada item del carrito ({ codigo, cantidad }) con los datos de su producto.
  // Si un producto ya no existe en el catálogo, se salta.
  const filas = []
  carrito.forEach((item) => {
    const producto = buscarProducto(item.codigo)
    if (producto) {
      filas.push({
        producto,
        cantidad: item.cantidad,
        subtotal: producto.precioResidencial * item.cantidad,
      })
    }
  })

  // Total a pagar: suma de los subtotales
  let total = 0
  filas.forEach((fila) => {
    total = total + fila.subtotal
  })

  // Botones − y +: cambian la cantidad y avisan si no hay stock
  function cambiarCantidad(codigo, nuevaCantidad) {
    const error = actualizarCantidad(codigo, nuevaCantidad)
    if (error) {
      alert(error)
    }
  }

  if (filas.length === 0) {
    return (
      <Container as="main" className="py-4">
        <h1>Mi carrito de compras</h1>
        <p>Tu carrito está vacío.</p>
        <Button as={Link} to="/productos" variant="primary">
          Ver productos
        </Button>
      </Container>
    )
  }

  return (
    <Container as="main" className="py-4">
      <h1>Mi carrito de compras</h1>

      <Table responsive className="tabla-carrito">
        <thead>
          <tr>
            <th></th>
            <th>Producto</th>
            <th>Precio</th>
            <th>Cantidad</th>
            <th>Subtotal</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {filas.map(({ producto, cantidad, subtotal }) => (
            <tr key={producto.codigo}>
              <td>
                <ImagenProducto producto={producto} className="imagen-carrito" />
              </td>
              <td>{producto.nombre}</td>
              <td>{formatearPrecio(producto.precioResidencial)}</td>
              <td className="text-nowrap">
                <Button
                  variant="outline-primary"
                  size="sm"
                  onClick={() => cambiarCantidad(producto.codigo, cantidad - 1)}
                >
                  −
                </Button>
                <span className="cantidad">{cantidad}</span>
                <Button
                  variant="outline-primary"
                  size="sm"
                  onClick={() => cambiarCantidad(producto.codigo, cantidad + 1)}
                >
                  +
                </Button>
              </td>
              <td>{formatearPrecio(subtotal)}</td>
              <td>
                <Button
                  variant="outline-primary"
                  onClick={() => quitarDelCarrito(producto.codigo)}
                >
                  Quitar
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>

      <p className="total-carrito">Total: {formatearPrecio(total)}</p>

      {/* Igual que en el Avance 1: el botón se muestra, pero aún no tiene acción */}
      <Button type="button" variant="primary">
        Pagar
      </Button>
    </Container>
  )
}

export default Carrito
