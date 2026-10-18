// src/components/UsuarioForm.jsx
// Formulario reutilizable de usuario: sirve para "nuevo" y para "editar".
// Props:
//   usuarioInicial: datos para precargar el formulario (solo al editar)
//   modoEditar: true al editar (el RUN queda bloqueado y la contraseña es opcional)
//   onGuardar: función que recibe el usuario ya validado
//   validarRun: función opcional para validar el RUN (por defecto, revisión de formato)

import { useState } from 'react'
import { Form, Button } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import { validarUsuario } from '../utils/validacionesUsuario'
import { obtenerUsuarios } from '../services/usuariosService'
import { comunasPorRegion, regiones } from '../data/regionesComunas'

const TIPOS_USUARIO = ['Administrador', 'Cliente', 'Vendedor']

const VACIO = {
  run: '',
  nombre: '',
  apellidos: '',
  correo: '',
  password: '',
  fechaNacimiento: '',
  tipoUsuario: '',
  region: '',
  comuna: '',
  direccion: '',
}

// Convierte los datos del usuario a texto para mostrarlos en los campos.
// La contraseña nunca se precarga.
function aTexto(usuario) {
  const resultado = {}
  Object.keys(VACIO).forEach((clave) => {
    resultado[clave] = String(usuario[clave] ?? '')
  })
  resultado.password = ''
  return resultado
}

function UsuarioForm({
  usuarioInicial = null,
  modoEditar = false,
  onGuardar = () => {},
  validarRun,
}) {
  const [valores, setValores] = useState(() => (usuarioInicial ? aTexto(usuarioInicial) : VACIO))
  const [errores, setErrores] = useState({})

  // Comunas disponibles según la región elegida
  const comunas = comunasPorRegion[valores.region] ?? []

  // Si el usuario tiene un tipo que no está en la lista, se agrega para no perderlo
  const tipos =
    valores.tipoUsuario && !TIPOS_USUARIO.includes(valores.tipoUsuario)
      ? [...TIPOS_USUARIO, valores.tipoUsuario]
      : TIPOS_USUARIO

  const manejarCambio = (evento) => {
    const { name, value } = evento.target
    setValores((anterior) => ({ ...anterior, [name]: value }))
    // Al escribir, se borra el error de ese campo
    setErrores((anterior) => ({ ...anterior, [name]: undefined }))
  }

  // Al cambiar la región, la comuna elegida deja de ser válida y se reinicia
  const manejarCambioRegion = (evento) => {
    const { value } = evento.target
    setValores((anterior) => ({ ...anterior, region: value, comuna: '' }))
    setErrores((anterior) => ({ ...anterior, region: undefined, comuna: undefined }))
  }

  const manejarEnvio = (evento) => {
    evento.preventDefault()

    const erroresEncontrados = validarUsuario(valores, obtenerUsuarios(), modoEditar, validarRun)
    setErrores(erroresEncontrados)

    if (Object.keys(erroresEncontrados).length > 0) return

    onGuardar({
      run: valores.run.trim().toUpperCase(),
      nombre: valores.nombre.trim(),
      apellidos: valores.apellidos.trim(),
      correo: valores.correo.trim().toLowerCase(),
      password: valores.password,
      fechaNacimiento: valores.fechaNacimiento,
      tipoUsuario: valores.tipoUsuario,
      region: valores.region,
      comuna: valores.comuna,
      direccion: valores.direccion.trim(),
    })
  }

  // Campo de texto con su mensaje de error
  const campo = (name, etiqueta, props = {}, ayuda = null) => (
    <Form.Group className="mb-3" controlId={name}>
      <Form.Label>{etiqueta}</Form.Label>
      <Form.Control
        name={name}
        value={valores[name]}
        onChange={manejarCambio}
        isInvalid={!!errores[name]}
        autoComplete="off"
        {...props}
      />
      <Form.Control.Feedback type="invalid">{errores[name]}</Form.Control.Feedback>
      {ayuda && <Form.Text muted>{ayuda}</Form.Text>}
    </Form.Group>
  )

  // Lista desplegable con su mensaje de error
  const campoSelect = (name, etiqueta, opciones, textoVacio, alCambiar = manejarCambio, props = {}) => (
    <Form.Group className="mb-3" controlId={name}>
      <Form.Label>{etiqueta}</Form.Label>
      <Form.Select
        name={name}
        value={valores[name]}
        onChange={alCambiar}
        isInvalid={!!errores[name]}
        {...props}
      >
        <option value="">{textoVacio}</option>
        {opciones.map((opcion) => (
          <option key={opcion} value={opcion}>
            {opcion}
          </option>
        ))}
      </Form.Select>
      <Form.Control.Feedback type="invalid">{errores[name]}</Form.Control.Feedback>
    </Form.Group>
  )

  return (
    <Form onSubmit={manejarEnvio} noValidate>
      {campo('run', 'RUN', { type: 'text', maxLength: 9, disabled: modoEditar, placeholder: 'Ej: 123456785' })}
      {campo('nombre', 'Nombre', { type: 'text', maxLength: 50 })}
      {campo('apellidos', 'Apellidos', { type: 'text', maxLength: 100 })}
      {campo('correo', 'Correo', { type: 'email', maxLength: 100, placeholder: 'ej: cliente@gmail.com' })}
      {campo(
        'password',
        'Contraseña',
        { type: 'password', maxLength: 10, autoComplete: 'new-password' },
        modoEditar ? 'Déjala en blanco para mantener la contraseña actual.' : null,
      )}
      {campo('fechaNacimiento', 'Fecha de nacimiento', { type: 'date' })}
      {campoSelect('tipoUsuario', 'Tipo de usuario', tipos, 'Seleccione')}
      {campoSelect('region', 'Región', regiones, 'Seleccione Región', manejarCambioRegion)}
      {campoSelect('comuna', 'Comuna', comunas, 'Seleccione Comuna', manejarCambio, {
        disabled: !valores.region,
      })}
      {campo('direccion', 'Dirección', { type: 'text', maxLength: 300 })}

      <Button variant="primary" type="submit" className="me-2">
        {modoEditar ? 'Guardar cambios' : 'Guardar usuario'}
      </Button>
      <Button as={Link} to="/admin/usuarios" variant="outline-secondary">
        Cancelar
      </Button>
    </Form>
  )
}

export default UsuarioForm