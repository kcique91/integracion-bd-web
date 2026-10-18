import { Navigate, NavLink, Outlet } from 'react-router-dom';
import { getUsuarioActivo, puedeAdministrar } from '../data/usuarios';
import '../styles/admin.css';

export default function AdminLayout({ children }) {
  const usuario = getUsuarioActivo();

  // Sin sesión: va al login. Con sesión pero sin permiso (Cliente): va al inicio.
  if (!usuario) {
    return <Navigate to="/login" replace />;
  }
  if (!puedeAdministrar(usuario)) {
    return <Navigate to="/" replace />;
  }
  
  return (
    <div className="admin-layout">
      <aside className="admin-sidebar">
        <h4>Panel Admin</h4>
        <ul className="admin-menu">
          <li>
            <NavLink
              to="/admin"
              end
              className={({ isActive }) => (isActive ? 'active' : '')}
            >
              Dashboard
            </NavLink>
          </li>
          <li>
            <NavLink
              to="/admin/productos"
              className={({ isActive }) => (isActive ? 'active' : '')}
            >
              Productos
            </NavLink>
          </li>
          <li>
            <NavLink
              to="/admin/usuarios"
              className={({ isActive }) => (isActive ? 'active' : '')}
            >
              Usuarios
            </NavLink>
          </li>
        </ul>
      </aside>
      <main className="admin-content">
        {children || <Outlet />}
      </main>
    </div>
  );
}