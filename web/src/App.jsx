import { Routes, Route } from 'react-router-dom'
import { CarritoProvider } from './context/CarritoContext'
import Menu from './components/Menu'
import PiePagina from './components/PiePagina'
import Home from './pages/Home'
import Productos from './pages/Productos'
import ProductoDetalle from './pages/ProductoDetalle'
import Nosotros from './pages/Nosotros'
import Blogs from './pages/Blogs'
import BlogDetalle1 from './pages/BlogDetalle1'
import BlogDetalle2 from './pages/BlogDetalle2'
import Contacto from './pages/Contacto'
import Login from './pages/Login'
import Registro from './pages/Registro'
import Carrito from './pages/Carrito'
import AdminHome from './pages/admin/AdminHome'
import AdminProductos from './pages/admin/AdminProductos'
import AdminUsuarios from './pages/admin/AdminUsuarios'
import ProductoNuevo from './pages/admin/ProductoNuevo'
import ProductoEditar from './pages/admin/ProductoEditar'
import UsuarioNuevo from './pages/admin/UsuarioNuevo'
import UsuarioEditar from './pages/admin/UsuarioEditar'
import './App.css'

// El BrowserRouter vive en main.jsx
function App() {
  return (
    <CarritoProvider>
      {/* min-vh-100 + flex-grow-1: el footer queda abajo aunque la página tenga poco contenido */}
      <div className="d-flex flex-column min-vh-100">
        <Menu />
        <div className="flex-grow-1">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/productos" element={<Productos />} />
            <Route path="/productos/:codigo" element={<ProductoDetalle />} />
            <Route path="/nosotros" element={<Nosotros />} />
            <Route path="/blogs" element={<Blogs />} />
            <Route path="/blogs/1" element={<BlogDetalle1 />} />
            <Route path="/blogs/2" element={<BlogDetalle2 />} />
            <Route path="/contacto" element={<Contacto />} />
            <Route path="/login" element={<Login />} />
            <Route path="/registro" element={<Registro />} />
            <Route path="/carrito" element={<Carrito />} />
            <Route path="/admin" element={<AdminHome />} />
            <Route path="/admin/productos" element={<AdminProductos />} />
            <Route path="/admin/usuarios" element={<AdminUsuarios />} />
            <Route path="/admin/productos/nuevo" element={<ProductoNuevo />} />
            <Route path="/admin/productos/editar/:codigo" element={<ProductoEditar />} />
            <Route path="/admin/usuarios/nuevo" element={<UsuarioNuevo />} />
            <Route path="/admin/usuarios/editar/:run" element={<UsuarioEditar />} />
          </Routes>
        </div>
        <PiePagina />
      </div>
    </CarritoProvider>
  )
}

export default App