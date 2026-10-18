// src/services/usuariosService.js
// Servicio de usuarios para los formularios del administrador.
// Se apoya en src/data/usuarios.js (lectura y registro con localStorage)
// y agrega lo que falta: buscar un usuario y actualizarlo.

import { obtenerUsuarios, registrarUsuario } from '../data/usuarios'

const CLAVE = 'usuarios'

// Se vuelve a exportar para que los formularios lo importen desde un solo lugar
export { obtenerUsuarios }

export function guardarUsuarios(lista) {
  localStorage.setItem(CLAVE, JSON.stringify(lista))
}

export function buscarUsuario(run) {
  return obtenerUsuarios().find((u) => u.run === run)
}

// Devuelve true si se guardó, o false si ya existía el correo o el RUN
export function agregarUsuario(usuario) {
  return registrarUsuario(usuario)
}

// Si la contraseña viene vacía, se mantiene la que ya tenía el usuario.
// Los campos que el formulario no edita (como el teléfono) se conservan.
export function actualizarUsuario(run, cambios) {
  const { password, ...resto } = cambios
  const lista = obtenerUsuarios().map((u) =>
    u.run === run ? { ...u, ...resto, run, ...(password ? { password } : {}) } : u,
  )
  guardarUsuarios(lista)
}