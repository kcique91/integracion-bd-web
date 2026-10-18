// src/data/regionesComunas.js
// Regiones y comunas de cobertura de la Distribuidora Gas El Volcán.
// Se usa en el select dependiente del formulario de usuario.

export const comunasPorRegion = {
  'Región de Ñuble': [
    'Chillán',
    'Chillán Viejo',
    'El Carmen',
    'Pinto',
    'San Ignacio',
    'Bulnes',
    'Quillón',
  ],
}

// Lista de regiones para el primer select
export const regiones = Object.keys(comunasPorRegion)