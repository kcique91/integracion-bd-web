// src/components/ProductoForm.jsx
// Formulario reutilizable de producto: sirve para "nuevo" y para "editar".
// Props:
//   productoInicial: datos para precargar el formulario (solo al editar)
//   modoEditar: true al editar (el código queda bloqueado)
//   onGuardar: función que recibe el producto ya validado

import { useState } from 'react'
import { Form, Button } from 'react-bootstrap'
import { Link } from 'react-router-dom'
import { validarProducto } from '../utils/validacionesProducto'
import { obtenerProductos } from '../services/productosService'

const CATEGORIAS = ['Cilindros de Gas', 'Reguladores', 'Mangueras y Conexiones', 'Accesorios']
const UNIDADES = ['Unidad', 'Kit']

const VACIO = {
  codigo: '',
  nombre: '',
  descripcion: '',
  categoria: '',
  unidad: '',
  precioResidencial: '',
  precioComercial: '',
  stock: '',
  stockCritico: '',
  imagen: '',
}

// Convierte los datos del producto a texto para poder mostrarlos en los campos
function aTexto(producto) {
  const resultado = {}
  Object.keys(VACIO).forEach((clave) => {
    resultado[clave] = String(producto[clave] ?? '')
  })
  return resultado
}

function ProductoForm({ productoInicial = null, modoEditar = false, onGuardar = () => {} }) {
  const [valores, setValores] = useState(() => (productoInicial ? aTexto(productoInicial) : VACIO))
  const [errores, setErrores] = useState({})

  const manejarCambio = (evento) => {
    const { name, value } = evento.target
    setValores((anterior) => ({ ...anterior, [name]: value }))
    // Al escribir, se borra el error de ese campo
    setErrores((anterior) => ({ ...anterior, [name]: undefined }))
  }

  const manejarEnvio = (evento) => {
    evento.preventDefault()

    const erroresEncontrados = validarProducto(valores, obtenerProductos(), modoEditar)
    setErrores(erroresEncontrados)

    if (Object.keys(erroresEncontrados).length > 0) return

    onGuardar({
      codigo: valores.codigo.trim(),
      categoria: valores.categoria,
      nombre: valores.nombre.trim(),
      descripcion: valores.descripcion.trim(),
      unidad: valores.unidad,
      precioResidencial: Number(valores.precioResidencial),
      precioComercial: Number(valores.precioComercial),
      stock: Number(valores.stock),
      stockCritico: valores.stockCritico !== '' ? Number(valores.stockCritico) : 0,
      imagen: valores.imagen.trim(),
    })
  }

  // Campo de texto o número con su mensaje de error
  const campo = (name, etiqueta, props = {}) => (
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
    </Form.Group>
  )

  // Lista desplegable con su mensaje de error
  const campoSelect = (name, etiqueta, opciones, textoVacio) => (
    <Form.Group className="mb-3" controlId={name}>
      <Form.Label>{etiqueta}</Form.Label>
      <Form.Select
        name={name}
        value={valores[name]}
        onChange={manejarCambio}
        isInvalid={!!errores[name]}
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
      {campo('codigo', 'Código', { type: 'text', disabled: modoEditar })}
      {campo('nombre', 'Nombre', { type: 'text' })}
      {campo('descripcion', 'Descripción', { as: 'textarea', rows: 3 })}
      {campoSelect('categoria', 'Categoría', CATEGORIAS, 'Seleccione una categoría')}
      {campoSelect('unidad', 'Unidad', UNIDADES, 'Seleccione')}
      {campo('precioResidencial', 'Precio Residencial', { type: 'number', min: 0, step: 1 })}
      {campo('precioComercial', 'Precio Comercial', { type: 'number', min: 0, step: 1 })}
      {campo('stock', 'Stock', { type: 'number', min: 0, step: 1 })}
      {campo('stockCritico', 'Stock Crítico', { type: 'number', min: 0, step: 1 })}
      {campo('imagen', 'Imagen', { type: 'text', placeholder: 'img/nombre-archivo.jpg' })}

      <Button variant="primary" type="submit" className="me-2">
        {modoEditar ? 'Guardar cambios' : 'Guardar producto'}
      </Button>
      <Button as={Link} to="/admin/productos" variant="outline-secondary">
        Cancelar
      </Button>
    </Form>
  )
}

export default ProductoForm