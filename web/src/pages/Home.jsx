import { Button, Col, Container, Row } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import TarjetaProducto from '../components/TarjetaProducto'
import { obtenerDestacados } from '../services/productosService'

function Home() {
  const destacados = obtenerDestacados()

  return (
    <Container as="main" className="py-4">
      <section className="hero text-center py-5">
        <h1>Bienvenido a Distribuidora de gas "El Volcán"</h1>
        <p>
          Cilindros de gas, reguladores, mangueras y accesorios, con despacho a
          domicilio en Chillán y alrededores.
        </p>
        <Button as={Link} to="/productos" variant="primary">
          Ver productos
        </Button>
      </section>

      <h2 className="my-4">Productos destacados</h2>
      <Row xs={1} sm={2} md={3} lg={4} className="g-3">
        {destacados.map((producto) => (
          <Col key={producto.codigo}>
            <TarjetaProducto producto={producto} />
          </Col>
        ))}
      </Row>
    </Container>
  )
}

export default Home