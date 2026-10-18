// src/utils/validacionesProducto.js
// Validaciones del formulario de producto (nuevo y editar).
// Devuelve un objeto con un mensaje de error por cada campo inválido.
// Si el objeto viene vacío, el formulario es válido.

export function validarProducto(datos, productosExistentes = [], modoEditar = false) {
  const errores = {}

  const codigo = String(datos.codigo ?? '').trim()
  const nombre = String(datos.nombre ?? '').trim()
  const descripcion = String(datos.descripcion ?? '').trim()

  // Código: solo se valida al crear (al editar no se puede cambiar)
  if (!modoEditar) {
    if (codigo.length < 3) {
      errores.codigo = 'El código es obligatorio y debe tener al menos 3 caracteres.'
    } else if (productosExistentes.some((p) => p.codigo === codigo)) {
      errores.codigo = 'Ya existe un producto con ese código.'
    }
  }

  // Nombre
  if (nombre.length === 0) {
    errores.nombre = 'El nombre es obligatorio.'
  } else if (nombre.length > 100) {
    errores.nombre = 'El nombre no puede superar los 100 caracteres.'
  }

  // Descripción (opcional, pero con máximo)
  if (descripcion.length > 500) {
    errores.descripcion = 'La descripción no puede superar los 500 caracteres.'
  }

  // Categoría y unidad
  if (!datos.categoria) {
    errores.categoria = 'Debes seleccionar una categoría.'
  }
  if (!datos.unidad) {
    errores.unidad = 'Debes seleccionar una unidad.'
  }

  // Precios: número de 0 o más
  if (!esNumeroValido(datos.precioResidencial)) {
    errores.precioResidencial = 'Ingresa un precio residencial válido (0 o mayor).'
  }
  if (!esNumeroValido(datos.precioComercial)) {
    errores.precioComercial = 'Ingresa un precio comercial válido (0 o mayor).'
  }

  // Stock: entero de 0 o más
  if (!esEnteroValido(datos.stock)) {
    errores.stock = 'El stock debe ser un número entero de 0 o más.'
  }

  // Stock crítico: opcional, pero si viene debe ser entero de 0 o más
  const stockCritico = datos.stockCritico
  if (stockCritico !== '' && stockCritico != null && !esEnteroValido(stockCritico)) {
    errores.stockCritico = 'El stock crítico debe ser un número entero de 0 o más.'
  }

  return errores
}

// Número (puede tener decimales) mayor o igual a 0
function esNumeroValido(valor) {
  if (valor === '' || valor == null) return false
  const numero = Number(valor)
  return !Number.isNaN(numero) && numero >= 0
}

// Número entero mayor o igual a 0
function esEnteroValido(valor) {
  if (valor === '' || valor == null) return false
  const numero = Number(valor)
  return Number.isInteger(numero) && numero >= 0
}