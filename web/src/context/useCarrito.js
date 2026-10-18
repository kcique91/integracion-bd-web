import { createContext, useContext } from 'react'

// El "canal" por donde CarritoProvider comparte el carrito con los componentes
export const CarritoContext = createContext()

// Atajo para leer el carrito desde cualquier componente
export function useCarrito() {
  return useContext(CarritoContext)
}
