import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { registrarUsuario } from '../data/usuarios';
import { validarRUN } from '../utils/validacionRun';

// Comunas reales de cobertura para Ñuble
const comunasNuble = [
  'Chillán',
  'Chillán Viejo',
  'El Carmen',
  'Pinto',
  'San Ignacio',
  'Bulnes',
  'Quillón'
];

export default function Registro() {
  const navigate = useNavigate();

  // Estados de los campos del formulario
  const [run, setRun] = useState('');
  const [nombre, setNombre] = useState('');
  const [apellidos, setApellidos] = useState('');
  const [correo, setCorreo] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [telefono, setTelefono] = useState('');
  const [fechaNacimiento, setFechaNacimiento] = useState('');
  const [region, setRegion] = useState('');
  const [comuna, setComuna] = useState('');
  const [direccion, setDireccion] = useState('');

  // Estados de mensajes
  const [error, setError] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');

  const dominiosValidos = ['@duoc.cl', '@profesor.duoc.cl', '@gmail.com'];

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');
    setMensajeExito('');

    // 1. Validar campos obligatorios
    if (!run || !nombre || !apellidos || !correo || !password || !confirmPassword || !region || !comuna || !direccion) {
      setError('Por favor, completa todos los campos obligatorios (*).');
      return;
    }

    // 2. Validar formato y dígito verificador del RUN
    const runLimpio = run.trim().toUpperCase();
    if (runLimpio.includes('.') || runLimpio.includes('-')) {
      setError('El RUN debe ingresarse sin puntos ni guión (ej: 123456785).');
      return;
    }

    if (!validarRUN(runLimpio)) {
      setError('El RUN ingresado no es válido (dígito verificador incorrecto).');
      return;
    }

    // 3. Validar correo institucional o gmail
    const correoMinuscula = correo.trim().toLowerCase();
    const dominioPermitido = dominiosValidos.some(d => correoMinuscula.endsWith(d));
    if (!dominioPermitido) {
      setError('El correo debe terminar en @duoc.cl, @profesor.duoc.cl o @gmail.com');
      return;
    }

    // 4. Validar contraseña
    if (password.length < 4 || password.length > 10) {
      setError('La contraseña debe tener entre 4 y 10 caracteres.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Las contraseñas no coinciden.');
      return;
    }

    // 5. Armar objeto usuario y guardar en usuarios.js
    const nuevoUsuario = {
      run: runLimpio,
      nombre: nombre.trim(),
      apellidos: apellidos.trim(),
      correo: correoMinuscula,
      password: password,
      telefono: telefono.trim() || 'No especificado',
      fechaNacimiento: fechaNacimiento || 'No especificada',
      tipoUsuario: 'Cliente',
      region: region,
      comuna: comuna,
      direccion: direccion.trim()
    };

    const exito = registrarUsuario(nuevoUsuario);

    if (exito) {
      setMensajeExito('¡Registro exitoso! Redirigiendo al inicio de sesión...');
      setTimeout(() => {
        navigate('/login');
      }, 1500);
    } else {
      setError('Este RUN o correo ya se encuentra registrado.');
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-12 col-md-8 col-lg-7">
          <div className="card shadow-sm border-0">
            <div className="card-body p-4">
              
              <div className="text-center mb-4">
                <h3 className="fw-bold text-primary">Crear Cuenta</h3>
                <p className="text-muted small">Regístrate para pedir gas licuado a domicilio</p>
              </div>

              {/* Alertas */}
              {error && <div className="alert alert-danger py-2 small">{error}</div>}
              {mensajeExito && <div className="alert alert-success py-2 small">{mensajeExito}</div>}

              <form onSubmit={handleSubmit}>
                
                {/* RUN */}
                <div className="mb-3">
                  <label className="form-label fw-semibold">RUN (sin puntos ni guión) *</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="Ej: 123456785"
                    maxLength={9}
                    value={run}
                    onChange={(e) => setRun(e.target.value)}
                  />
                </div>

                {/* Nombre y Apellidos */}
                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Nombre *</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="Ej: Juan"
                      maxLength={50}
                      value={nombre}
                      onChange={(e) => setNombre(e.target.value)}
                    />
                  </div>
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Apellidos *</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="Ej: Pérez González"
                      maxLength={100}
                      value={apellidos}
                      onChange={(e) => setApellidos(e.target.value)}
                    />
                  </div>
                </div>

                {/* Correo */}
                <div className="mb-3">
                  <label className="form-label fw-semibold">Correo electrónico *</label>
                  <input
                    type="email"
                    className="form-control"
                    placeholder="ejemplo@duoc.cl o @gmail.com"
                    maxLength={100}
                    value={correo}
                    onChange={(e) => setCorreo(e.target.value)}
                  />
                </div>

                {/* Contraseñas */}
                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Contraseña *</label>
                    <input
                      type="password"
                      className="form-control"
                      placeholder="4 a 10 caracteres"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                    />
                  </div>
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Confirmar Contraseña *</label>
                    <input
                      type="password"
                      className="form-control"
                      placeholder="Repite la contraseña"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                    />
                  </div>
                </div>

                {/* Teléfono y Fecha Nacimiento */}
                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Teléfono (opcional)</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="Ej: 912345678"
                      value={telefono}
                      onChange={(e) => setTelefono(e.target.value)}
                    />
                  </div>
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Fecha de Nacimiento (opcional)</label>
                    <input
                      type="date"
                      className="form-control"
                      value={fechaNacimiento}
                      onChange={(e) => setFechaNacimiento(e.target.value)}
                    />
                  </div>
                </div>

                {/* Región y Comuna dependiente */}
                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Región *</label>
                    <select
                      className="form-select"
                      value={region}
                      onChange={(e) => {
                        setRegion(e.target.value);
                        setComuna(''); // Resetear comuna al cambiar región
                      }}
                    >
                      <option value="">Selecciona una región</option>
                      <option value="Región de Ñuble">Región de Ñuble</option>
                    </select>
                  </div>
                  <div className="col-md-6 mb-3">
                    <label className="form-label fw-semibold">Comuna *</label>
                    <select
                      className="form-select"
                      value={comuna}
                      disabled={!region}
                      onChange={(e) => setComuna(e.target.value)}
                    >
                      <option value="">
                        {region ? 'Selecciona una comuna' : 'Primero elige la región'}
                      </option>
                      {comunasNuble.map((c) => (
                        <option key={c} value={c}>{c}</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Dirección */}
                <div className="mb-4">
                  <label className="form-label fw-semibold">Dirección de entrega *</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="Ej: Calle Los Puelches 123"
                    maxLength={300}
                    value={direccion}
                    onChange={(e) => setDireccion(e.target.value)}
                  />
                </div>

                <button type="submit" className="btn btn-primary w-100 fw-bold py-2">
                  Completar Registro
                </button>
              </form>

              <div className="text-center mt-3">
                <span className="text-muted small">¿Ya tienes una cuenta? </span>
                <Link to="/login" className="small fw-bold text-decoration-none">
                  Inicia sesión aquí
                </Link>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  );
}