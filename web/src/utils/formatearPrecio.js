// Formatea un número como precio en pesos chilenos. Ej: 12000 -> "$12.000"
export function formatearPrecio(valor) {
  return `$${valor.toLocaleString('es-CL')}`
}
