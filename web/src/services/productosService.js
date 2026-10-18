// src/services/productosService.js
// Lee y guarda los productos en localStorage.
// Si todavía no hay cambios guardados, parte con el catálogo de src/data/productos.js

import { productos as productosIniciales } from '../data/productos'

const CLAVE = 'productos'

export function obtenerProductos() {
  try {
    const guardado = localStorage.getItem(CLAVE)
    if (guardado) {
      const lista = JSON.parse(guardado)
      if (Array.isArray(lista) && lista.length > 0) return lista
    }
  } catch {
    // Si localStorage falla, se usa el catálogo inicial
  }
  return productosIniciales
}

export function guardarProductos(lista) {
  localStorage.setItem(CLAVE, JSON.stringify(lista))
}

export function buscarProducto(codigo) {
  return obtenerProductos().find((p) => p.codigo === codigo)
}

export function agregarProducto(producto) {
  const lista = [...obtenerProductos(), producto]
  guardarProductos(lista)
}

export function actualizarProducto(codigo, cambios) {
  const lista = obtenerProductos().map((p) =>
    p.codigo === codigo ? { ...p, ...cambios, codigo } : p,
  )
  guardarProductos(lista)
}


// Productos de la misma categoría (para la sección "Relacionados" del detalle)
export function obtenerRelacionados(producto) {
  return obtenerProductos().filter(
    (p) => p.categoria === producto.categoria && p.codigo !== producto.codigo,
  )
}

// Los primeros 4 productos (para el Home)
export function obtenerDestacados() {
  return obtenerProductos().slice(0, 4)
}