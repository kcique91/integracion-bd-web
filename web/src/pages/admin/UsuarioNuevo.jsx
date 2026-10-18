// src/pages/admin/UsuarioNuevo.jsx
// Página para crear un usuario: usa el formulario y guarda con el servicio.
// El RUN se valida con validarRUN (dígito verificador), hecho por B.

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Alert } from 'react-bootstrap'
import AdminLayout from '../../components/AdminLayout'
import UsuarioForm from '../../components/UsuarioForm'
import { agregarUsuario } from '../../services/usuariosService'
import { validarRUN } from '../../utils/validacionRun'

export default function UsuarioNuevo() {
  const navigate = useNavigate()
  const [errorGuardado, setErrorGuardado] = useState('')

  // Se ejecuta cuando el formulario ya validó los datos
  const manejarGuardar = (usuario) => {
    const guardado = agregarUsuario(usuario)

    if (guardado) {
      navigate('/admin/usuarios')
    } else {
      setErrorGuardado('No se pudo guardar: ya existe un usuario con ese RUN o correo.')
    }
  }

  return (
    <AdminLayout>
      <h2>Nuevo Usuario</h2>
      <div className="mt-3 col-12 col-md-10 col-lg-6">
        {errorGuardado && <Alert variant="danger">{errorGuardado}</Alert>}
        <UsuarioForm onGuardar={manejarGuardar} validarRun={validarRUN} />
      </div>
    </AdminLayout>
  )
}