import { useEffect, useState } from 'react'
import { CarritoContext } from './useCarrito'
import { buscarProducto } from '../services/productosService'

// Lee el carrito guardado en localStorage; si no hay nada, devuelve un arreglo vacío
function obtenerCarritoGuardado() {
  const texto = localStorage.getItem('carrito')
  if (texto === null) {
    return []
  }
  return JSON.parse(texto)
}

// Envuelve la app y comparte el carrito con todos los componentes de adentro
export function CarritoProvider({ children }) {
  const [carrito, setCarrito] = useState(obtenerCarritoGuardado)

  // Cada vez que cambia el carrito, se guarda en localStorage
  useEffect(() => {
    localStorage.setItem('carrito', JSON.stringify(carrito))
  }, [carrito])

  // Suma las unidades de todos los productos (lo que muestra "Cart (N)" en el menú)
  let totalUnidades = 0
  carrito.forEach((item) => {
    totalUnidades = totalUnidades + item.cantidad
  })

  // Agrega una cantidad de un producto al carrito, respetando el stock disponible.
  // Devuelve el mensaje que el componente le muestra al usuario.
  function agregarAlCarrito(codigo, cantidad) {
    const producto = buscarProducto(codigo)
    if (producto === undefined) {
      return 'Producto no encontrado'
    }

    if (!Number.isInteger(cantidad) || cantidad < 1) {
      return 'Ingresa una cantidad válida (número entero mayor que 0)'
    }

    const itemExistente = carrito.find((item) => item.codigo === codigo)
    const cantidadActual = itemExistente ? itemExistente.cantidad : 0
    const cantidadNueva = cantidadActual + cantidad

    if (cantidadNueva > producto.stock) {
      return `No hay suficiente stock. Disponible: ${producto.stock} (ya tienes ${cantidadActual} en el carrito)`
    }

    // No se modifica el arreglo actual: se crea uno nuevo para que React note el cambio
    if (itemExistente) {
      setCarrito(
        carrito.map((item) =>
          item.codigo === codigo ? { ...item, cantidad: cantidadNueva } : item,
        ),
      )
    } else {
      setCarrito([...carrito, { codigo, cantidad: cantidadNueva }])
    }

    return 'Producto agregado al carrito'
  }

  // Elimina por completo un producto del carrito
  function quitarDelCarrito(codigo) {
    setCarrito(carrito.filter((item) => item.codigo !== codigo))
  }

  // Cambia la cantidad de un producto ya agregado; si la nueva cantidad es 0 o menos, lo quita.
  // Devuelve un mensaje de error si no hay stock, o null si todo salió bien.
  function actualizarCantidad(codigo, nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      quitarDelCarrito(codigo)
      return null
    }

    const producto = buscarProducto(codigo)
    if (producto === undefined) {
      return 'Producto no encontrado'
    }

    if (nuevaCantidad > producto.stock) {
      return `No hay suficiente stock. Disponible: ${producto.stock}`
    }

    setCarrito(
      carrito.map((item) =>
        item.codigo === codigo ? { ...item, cantidad: nuevaCantidad } : item,
      ),
    )
    return null
  }

  return (
    <CarritoContext
      value={{ carrito, totalUnidades, agregarAlCarrito, quitarDelCarrito, actualizarCantidad }}
    >
      {children}
    </CarritoContext>
  )
}
