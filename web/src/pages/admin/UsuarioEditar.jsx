// src/pages/admin/UsuarioEditar.jsx
// Página para editar un usuario: lee el RUN desde la URL,
// precarga el formulario y guarda los cambios con el servicio.

import { Link, useNavigate, useParams } from 'react-router-dom'
import { Alert } from 'react-bootstrap'
import AdminLayout from '../../components/AdminLayout'
import UsuarioForm from '../../components/UsuarioForm'
import { actualizarUsuario, buscarUsuario } from '../../services/usuariosService'

export default function UsuarioEditar() {
  const { run } = useParams()
  const navigate = useNavigate()
  const usuario = buscarUsuario(run)

  // Se ejecuta cuando el formulario ya validó los datos
  const manejarGuardar = (cambios) => {
    actualizarUsuario(run, cambios)
    navigate('/admin/usuarios')
  }

  return (
    <AdminLayout>
      <h2>Editar Usuario</h2>

      {usuario ? (
        <div className="mt-3 col-12 col-md-10 col-lg-6">
          <UsuarioForm
            key={run}
            usuarioInicial={usuario}
            modoEditar
            onGuardar={manejarGuardar}
          />
        </div>
      ) : (
        <Alert variant="warning" className="mt-3">
          No se encontró un usuario con el RUN {run}.{' '}
          <Link to="/admin/usuarios">Volver a usuarios</Link>
        </Alert>
      )}
    </AdminLayout>
  )
}