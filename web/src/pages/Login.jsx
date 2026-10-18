import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { loginUsuario } from '../data/usuarios';
import logo from '../assets/logo.jpg';

export default function Login() {
  const navigate = useNavigate();

  // Estados del formulario
  const [correo, setCorreo] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');

  // Dominios permitidos según la pauta
  const dominiosValidos = ['@duoc.cl', '@profesor.duoc.cl', '@gmail.com'];

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');
    setMensajeExito('');

    // 1. Validar que no estén vacíos
    if (!correo.trim() || !password.trim()) {
      setError('Por favor, completa todos los campos.');
      return;
    }

    // 2. Validar dominios permitidos
    const correoMinuscula = correo.trim().toLowerCase();
    const esValido = dominiosValidos.some(d => correoMinuscula.endsWith(d));
    if (!esValido) {
      setError('El correo debe terminar en @duoc.cl, @profesor.duoc.cl o @gmail.com');
      return;
    }

    // 3. Validar largo de la contraseña (entre 4 y 10)
    if (password.length < 4 || password.length > 10) {
      setError('La contraseña debe tener entre 4 y 10 caracteres.');
      return;
    }

    // 4. Intentar iniciar sesión contra nuestro archivo usuarios.js
    const usuario = loginUsuario(correoMinuscula, password);

    if (usuario) {
      setMensajeExito(`¡Bienvenido ${usuario.nombre}! (${usuario.tipoUsuario})`);
      
      // Redirigir al home después de 1.5 segundos
      setTimeout(() => {
        navigate('/');
      }, 1500);
    } else {
      setError('Correo o contraseña incorrectos.');
    }
  };

  return (
    <div className="container py-4">
      <div className="row justify-content-center">
        <div className="col-12 col-md-6 col-lg-5">
          <div className="card shadow-sm border-0">
            <div className="card-body p-4">
              
              {/* Logo y Encabezado */}
              <div className="text-center mb-4">
                <img 
                  src={logo} 
                  alt="Gas El Volcán" 
                  style={{ height: '60px', objectFit: 'contain' }}
                  className="mb-2"
                />
                <h3 className="fw-bold text-primary">Gas El Volcán</h3>
                <p className="text-muted small">Ingresa tus credenciales para continuar</p>
              </div>

              {/* Mensajes de Alerta */}
              {error && (
                <div className="alert alert-danger py-2 small" role="alert">
                  {error}
                </div>
              )}
              {mensajeExito && (
                <div className="alert alert-success py-2 small" role="alert">
                  {mensajeExito}
                </div>
              )}

              {/* Formulario */}
              <form onSubmit={handleSubmit}>
                <div className="mb-3">
                  <label className="form-label fw-semibold">Correo electrónico</label>
                  <input
                    type="email"
                    className="form-control"
                    placeholder="ejemplo@duoc.cl o @gmail.com"
                    value={correo}
                    onChange={(e) => setCorreo(e.target.value)}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label fw-semibold">Contraseña</label>
                  <input
                    type="password"
                    className="form-control"
                    placeholder="De 4 a 10 caracteres"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                </div>

                <button type="submit" className="btn btn-primary w-100 fw-bold py-2 mt-2">
                  Iniciar Sesión
                </button>
              </form>

              {/* Enlace a Registro */}
              <div className="text-center mt-4">
                <span className="text-muted small">¿No tienes cuenta? </span>
                <Link to="/registro" className="small fw-bold text-decoration-none">
                  Regístrate aquí
                </Link>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  );
}