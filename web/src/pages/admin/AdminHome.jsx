import { Row, Col, Card } from 'react-bootstrap';
import AdminLayout from '../../components/AdminLayout';
import { obtenerProductos } from '../../services/productosService';
import { obtenerUsuarios } from '../../services/usuariosService';

export default function AdminHome() {
  return (
    <AdminLayout paginaActual="admin-home">
      <h2>Dashboard de Administración</h2>
      <p className="text-muted">Resumen general del sistema</p>

      <Row className="g-4 mt-2">
        <Col md={6}>
          <Card className="shadow-sm border-primary">
            <Card.Body>
              <Card.Title>Total de Productos</Card.Title>
              <h3 className="display-6 text-primary">{obtenerProductos().length}</h3>
            </Card.Body>
          </Card>
        </Col>
        <Col md={6}>
          <Card className="shadow-sm border-success">
            <Card.Body>
              <Card.Title>Total de Usuarios</Card.Title>
              <h3 className="display-6 text-success">{obtenerUsuarios().length}</h3>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </AdminLayout>
  );
}