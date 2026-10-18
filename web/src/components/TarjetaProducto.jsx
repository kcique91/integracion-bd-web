import { Button, Card } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import ImagenProducto from './ImagenProducto'
import { useCarrito } from '../context/useCarrito'
import { formatearPrecio } from '../utils/formatearPrecio'
import './TarjetaProducto.css'

// conBotonAnadir permite ocultar "Añadir" (por ejemplo, en productos relacionados)
function TarjetaProducto({ producto, conBotonAnadir = true }) {
  const { agregarAlCarrito } = useCarrito()

  // Agrega 1 unidad del producto y avisa el resultado
  function manejarAnadir() {
    const mensaje = agregarAlCarrito(producto.codigo, 1)
    alert(mensaje)
  }

  return (
    <Card className="tarjeta-producto h-100">
      <Card.Body className="d-flex flex-column">
        <ImagenProducto producto={producto} className="imagen-producto" />
        <Card.Title as="h3">{producto.nombre}</Card.Title>
        <p className="precio">{formatearPrecio(producto.precioResidencial)}</p>

        <div className="acciones mt-auto">
          <Button
            as={Link}
            to={`/productos/${producto.codigo}`}
            variant="outline-primary"
          >
            Ver detalle
          </Button>
          {conBotonAnadir && (
            <Button type="button" variant="primary" onClick={manejarAnadir}>
              Añadir
            </Button>
          )}
        </div>
      </Card.Body>
    </Card>
  )
}

export default TarjetaProducto
