// src/utils/validacionesUsuario.js
// Validaciones del formulario de usuario (nuevo y editar).
// Devuelve un objeto con un mensaje de error por cada campo inválido.
// Si el objeto viene vacío, el formulario es válido.
//
// validarRun: función que recibe el RUN y devuelve true/false.
// Por ahora se usa una revisión básica de formato. Cuando B entregue
// validarRUN (dígito verificador), se pasa esa función en su lugar.

export function revisarFormatoRun(run) {
  return /^[0-9]{6,8}[0-9K]$/.test(String(run).trim().toUpperCase())
}

export function validarUsuario(
  datos,
  usuariosExistentes = [],
  modoEditar = false,
  validarRun = revisarFormatoRun,
) {
  const errores = {}

  const run = String(datos.run ?? '').trim().toUpperCase()
  const nombre = String(datos.nombre ?? '').trim()
  const apellidos = String(datos.apellidos ?? '').trim()
  const correo = String(datos.correo ?? '').trim().toLowerCase()
  const password = String(datos.password ?? '')
  const direccion = String(datos.direccion ?? '').trim()

  // RUN: solo se valida al crear (al editar queda bloqueado)
  if (!modoEditar) {
    if (!validarRun(run)) {
      errores.run = 'RUN inválido. Formato: sin puntos ni guion, ej. 123456785.'
    } else if (usuariosExistentes.some((u) => String(u.run ?? '').toUpperCase() === run)) {
      errores.run = 'Ya existe un usuario registrado con ese RUN.'
    }
  }

  // Nombre y apellidos
  if (nombre.length === 0) {
    errores.nombre = 'El nombre es obligatorio.'
  } else if (nombre.length > 50) {
    errores.nombre = 'El nombre no puede superar los 50 caracteres.'
  }

  if (apellidos.length === 0) {
    errores.apellidos = 'Los apellidos son obligatorios.'
  } else if (apellidos.length > 100) {
    errores.apellidos = 'Los apellidos no pueden superar los 100 caracteres.'
  }

  // Correo: obligatorio, dominio permitido y no repetido
  if (correo.length === 0 || correo.length > 100) {
    errores.correo = 'El correo es obligatorio (máx. 100 caracteres).'
  } else if (!/@(duoc\.cl|profesor\.duoc\.cl|gmail\.com)$/.test(correo)) {
    errores.correo = 'El correo debe ser @duoc.cl, @profesor.duoc.cl o @gmail.com.'
  } else if (
    usuariosExistentes.some(
      (u) =>
        String(u.correo ?? '').toLowerCase() === correo &&
        String(u.run ?? '').toUpperCase() !== run, // al editar, no cuenta el mismo usuario
    )
  ) {
    errores.correo = 'Ya existe un usuario registrado con ese correo.'
  }

  // Contraseña: obligatoria al crear; opcional al editar
  if (modoEditar && password === '') {
    // se mantiene la contraseña actual
  } else if (password.length < 4 || password.length > 10) {
    errores.password = 'La contraseña debe tener entre 4 y 10 caracteres.'
  }

  // Fecha de nacimiento: opcional, pero no puede ser futura
  if (datos.fechaNacimiento && new Date(datos.fechaNacimiento) > new Date()) {
    errores.fechaNacimiento = 'La fecha de nacimiento no puede ser futura.'
  }

  // Selects y dirección
  if (!datos.tipoUsuario) {
    errores.tipoUsuario = 'Debes seleccionar un tipo de usuario.'
  }
  if (!datos.region) {
    errores.region = 'Debes seleccionar una región.'
  }
  if (!datos.comuna) {
    errores.comuna = 'Debes seleccionar una comuna.'
  }

  if (direccion.length === 0) {
    errores.direccion = 'La dirección es obligatoria.'
  } else if (direccion.length > 300) {
    errores.direccion = 'La dirección no puede superar los 300 caracteres.'
  }

  return errores
}