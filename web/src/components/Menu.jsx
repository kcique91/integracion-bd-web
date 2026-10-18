import { Container, Nav, Navbar } from 'react-bootstrap'
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom'
import { useCarrito } from '../context/useCarrito'
import { getUsuarioActivo, logout, puedeAdministrar } from '../data/usuarios'
import logo from '../assets/logo.jpg'
import './Menu.css'

const enlacesPrincipales = [
  { to: '/', texto: 'Home' },
  { to: '/productos', texto: 'Productos' },
  { to: '/nosotros', texto: 'Nosotros' },
  { to: '/blogs', texto: 'Blogs' },
  { to: '/contacto', texto: 'Contacto' },
]

function Menu() {
  const { totalUnidades } = useCarrito()
  // Hace que el Menú se vuelva a dibujar cada vez que cambia la página
  useLocation()
  const navigate = useNavigate()

  // Se lee en cada render: null si nadie ha iniciado sesión
  const usuario = getUsuarioActivo()

  function cerrarSesion() {
    logout()
    navigate('/')
  }

  return (
    <Navbar expand="lg" className="menu">
      <Container fluid>
        <Navbar.Brand as={Link} to="/" className="menu-logo">
          <img src={logo} alt="Logo Gas El Volcán" />
          <span>Gas El Volcán</span>
        </Navbar.Brand>

        <Navbar.Toggle aria-controls="menu-principal" />

        <Navbar.Collapse id="menu-principal">
          <Nav className="menu-principal mx-auto">
            {enlacesPrincipales.map(({ to, texto }) => (
              <Nav.Link key={to} as={NavLink} to={to} end={to === '/'}>
                {texto}
              </Nav.Link>
            ))}
          </Nav>

          <Nav className="acciones-usuario">
            {usuario ? (
              <>
                {puedeAdministrar(usuario) && (
                  <Nav.Link as={NavLink} to="/admin" className="btn-admin">
                    Ir a Admin
                  </Nav.Link>
                )}
                <Nav.Link as="span" className="saludo-usuario">
                  👤 {usuario.nombre.split(' ')[0]}
                </Nav.Link>
                <Nav.Link onClick={cerrarSesion} className="btn-logout">
                  Cerrar sesión
                </Nav.Link>
              </>
            ) : (
              <>
                <Nav.Link as={NavLink} to="/login" className="btn-login">
                  Iniciar sesión
                </Nav.Link>
                <Nav.Link as={NavLink} to="/registro" className="btn-registro">
                  Registrar usuario
                </Nav.Link>
              </>
            )}
            <Nav.Link as={NavLink} to="/carrito" className="btn-carrito">
              🛒 Cart ({totalUnidades})
            </Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  )
}

export default Menu