import { Col, Container, Row } from 'react-bootstrap'
import TarjetaProducto from '../components/TarjetaProducto'
import { obtenerProductos } from '../services/productosService'

function Productos() {
  const productos = obtenerProductos()
  return (
    <Container as="main" className="py-4">
      <h1 className="mb-4">Nuestros Productos</h1>

      <Row xs={1} sm={2} md={3} lg={4} className="g-3">
        {productos.map((producto) => (
          <Col key={producto.codigo}>
            <TarjetaProducto producto={producto} />
          </Col>
        ))}
      </Row>
    </Container>
  )
}

export default Productos
