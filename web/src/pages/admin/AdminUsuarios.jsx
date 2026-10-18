// src/pages/admin/AdminUsuarios.jsx
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import AdminLayout from '../../components/AdminLayout';
import { obtenerUsuarios } from '../../services/usuariosService';

export default function AdminUsuarios() {
  const usuarios = obtenerUsuarios();

  return (
    <AdminLayout paginaActual="admin-usuarios">
      <div className="d-flex justify-content-between align-items-center flex-wrap gap-2">
        <h2 className="mb-0">Gestión de Usuarios</h2>
        <Button as={Link} to="/admin/usuarios/nuevo" variant="primary">
          Nuevo usuario
        </Button>
      </div>
      <Table striped bordered hover responsive className="table-admin mt-3">
        <thead className="table-dark">
          <tr>
            <th>RUN</th>
            <th>Nombre</th>
            <th>Apellidos</th>
            <th>Correo</th>
            <th>Tipo</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          {usuarios.map((usr) => (
            <tr key={usr.run}>
              <td>{usr.run}</td>
              <td>{usr.nombre}</td>
              <td>{usr.apellidos}</td>
              <td>{usr.correo}</td>
              <td>{usr.tipoUsuario}</td>
              <td>
                <Button
                  as={Link}
                  to={`/admin/usuarios/editar/${usr.run}`}
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