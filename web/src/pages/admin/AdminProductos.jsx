import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import AdminLayout from '../../components/AdminLayout';
import { obtenerProductos } from '../../services/productosService';

export default function AdminProductos() {
  const productos = obtenerProductos();

  return (
    <AdminLayout>
      <div className="d-flex justify-content-between align-items-center flex-wrap gap-2">
        <h2 className="mb-0">Gestión de Productos</h2>
        <Button as={Link} to="/admin/productos/nuevo" variant="primary">
          Nuevo producto
        </Button>
      </div>
      <Table striped bordered hover responsive className="table-admin mt-3">
        <thead className="table-dark">
          <tr>
            <th>Código</th>
            <th>Nombre</th>
            <th>Precio</th>
            <th>Stock</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          {productos.map((prod) => (
            <tr key={prod.codigo}>
              <td>{prod.codigo}</td>
              <td>{prod.nombre}</td>
              <td>${Number(prod.precioResidencial).toLocaleString('es-CL')}</td>
              <td>{prod.stock}</td>
              <td>
                <Button
                  as={Link}
                  to={`/admin/productos/editar/${prod.codigo}`}
                  variant="warning"
                  size="sm"
                >
                  Editar
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>
    </AdminLayout>
  );
}