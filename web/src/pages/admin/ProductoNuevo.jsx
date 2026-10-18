// src/pages/admin/ProductoNuevo.jsx
// Página para crear un producto: usa el formulario y guarda con el servicio.

import { useNavigate } from 'react-router-dom'
import AdminLayout from '../../components/AdminLayout'
import ProductoForm from '../../components/ProductoForm'
import { agregarProducto } from '../../services/productosService'

export default function ProductoNuevo() {
  const navigate = useNavigate()

  // Se ejecuta cuando el formulario ya validó los datos
  const manejarGuardar = (producto) => {
    agregarProducto(producto)
    navigate('/admin/productos')
  }

  return (
    <AdminLayout>
      <h2>Nuevo Producto</h2>
      <div className="mt-3 col-12 col-md-10 col-lg-6">
        <ProductoForm onGuardar={manejarGuardar} />
      </div>
    </AdminLayout>
  )
}