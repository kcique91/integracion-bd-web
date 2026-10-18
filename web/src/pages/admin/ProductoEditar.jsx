// src/pages/admin/ProductoEditar.jsx
// Página para editar un producto: lee el código desde la URL,
// precarga el formulario y guarda los cambios con el servicio.

import { Link, useNavigate, useParams } from 'react-router-dom'
import { Alert } from 'react-bootstrap'
import AdminLayout from '../../components/AdminLayout'
import ProductoForm from '../../components/ProductoForm'
import { actualizarProducto, buscarProducto } from '../../services/productosService'

export default function ProductoEditar() {
  const { codigo } = useParams()
  const navigate = useNavigate()
  const producto = buscarProducto(codigo)

  // Se ejecuta cuando el formulario ya validó los datos
  const manejarGuardar = (cambios) => {
    actualizarProducto(codigo, cambios)
    navigate('/admin/productos')
  }

  return (
    <AdminLayout>
      <h2>Editar Producto</h2>

      {producto ? (
        <div className="mt-3 col-12 col-md-10 col-lg-6">
          <ProductoForm
            key={codigo}
            productoInicial={producto}
            modoEditar
            onGuardar={manejarGuardar}
          />
        </div>
      ) : (
        <Alert variant="warning" className="mt-3">
          No se encontró un producto con el código {codigo}.{' '}
          <Link to="/admin/productos">Volver a productos</Link>
        </Alert>
      )}
    </AdminLayout>
  )
}