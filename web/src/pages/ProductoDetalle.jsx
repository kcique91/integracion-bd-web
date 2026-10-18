import { Breadcrumb, Button, Col, Container, Form, Row } from 'react-bootstrap'
import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import ImagenProducto from '../components/ImagenProducto'
import TarjetaProducto from '../components/TarjetaProducto'
import { useCarrito } from '../context/useCarrito'
import { buscarProducto, obtenerRelacionados } from '../services/productosService'
import { formatearPrecio } from '../utils/formatearPrecio'

// Campo "Cantidad" + botón "Añadir al carrito".
// ProductoDetalle lo usa con key={producto.codigo}: al cambiar de producto, React crea
// un formulario nuevo y la cantidad vuelve a 1.
function FormularioCantidad({ producto }) {
  const { agregarAlCarrito } = useCarrito()
  // Lo que el usuario escribe en el campo "Cantidad" (texto, se convierte al agregar)
  const [cantidad, setCantidad] = useState('1')

  // Agrega la cantidad escrita al carrito y avisa el resultado
  function manejarAnadir(evento) {
    evento.preventDefault() // evita que el formulario recargue la página (ej: al apretar Enter)
    const mensaje = agregarAlCarrito(producto.codigo, Number(cantidad))
    alert(mensaje)
  }

  return (
    <Form className="d-flex align-items-center gap-2" onSubmit={manejarAnadir}>
      <Form.Label htmlFor="inputCantidad" className="mb-0">Cantidad:</Form.Label>
      <Form.Control
        id="inputCantidad"
        type="number"
        value={cantidad}
        onChange={(evento) => setCantidad(evento.target.value)}
        min={1}
        max={producto.stock}
        style={{ width: '90px' }}
      />
      <Button type="submit" variant="primary">Añadir al carrito</Button>
    </Form>
  )
}

function ProductoDetalle() {
  const { codigo } = useParams()
  const producto = buscarProducto(codigo)

  if (!producto) {
    return (
      <Container as="main" className="py-4">
        <h1>Producto no encontrado</h1>
        <p>No existe un producto con el código "{codigo}".</p>
        <Link to="/productos">← Volver a productos</Link>
      </Container>
    )
  }

  const relacionados = obtenerRelacionados(producto)

  return (
    <Container as="main" className="py-4">
      <Breadcrumb>
        <Breadcrumb.Item linkAs={Link} linkProps={{ to: '/' }}>Home</Breadcrumb.Item>
        <Breadcrumb.Item linkAs={Link} linkProps={{ to: '/productos' }}>Productos</Breadcrumb.Item>
        <Breadcrumb.Item active>{producto.categoria}</Breadcrumb.Item>
        <Breadcrumb.Item active>{producto.nombre}</Breadcrumb.Item>
      </Breadcrumb>

      <Row className="align-items-center g-4 mb-5">
        <Col md={5} className="text-center">
          <ImagenProducto producto={producto} className="imagen-producto-grande" />
        </Col>
        <Col md={7}>
          <h2>{producto.nombre}</h2>
          <p className="fs-4 fw-bold" style={{ color: 'var(--color-primario)' }}>
            {formatearPrecio(producto.precioResidencial)}
          </p>
          <p>{producto.descripcion}</p>

          <FormularioCantidad key={producto.codigo} producto={producto} />
        </Col>
      </Row>

      {relacionados.length > 0 && (
        <>
          <h2 className="mb-3">Productos relacionados</h2>
          <Row xs={1} sm={2} md={3} lg={4} className="g-3">
            {relacionados.map((p) => (
              <Col key={p.codigo}>
                <TarjetaProducto producto={p} conBotonAnadir={false} />
              </Col>
            ))}
          </Row>
        </>
      )}
    </Container>
  )
}

export default ProductoDetalle
