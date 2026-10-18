import { useState } from 'react';

export default function Contacto() {
  // Estados para los campos
  const [nombre, setNombre] = useState('');
  const [correo, setCorreo] = useState('');
  const [comentario, setComentario] = useState('');

  // Estados de mensajes
  const [error, setError] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');

  const dominiosValidos = ['@duoc.cl', '@profesor.duoc.cl', '@gmail.com'];

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');
    setMensajeExito('');

    // 1. Validar campos obligatorios
    if (!nombre.trim() || !correo.trim() || !comentario.trim()) {
      setError('Por favor, completa todos los campos.');
      return;
    }

    // 2. Validar largo de nombre
    if (nombre.trim().length < 3) {
      setError('El nombre debe tener al menos 3 caracteres.');
      return;
    }

    // 3. Validar dominio del correo
    const correoMinuscula = correo.trim().toLowerCase();
    const dominioPermitido = dominiosValidos.some(d => correoMinuscula.endsWith(d));
    if (!dominioPermitido) {
      setError('El correo debe terminar en @duoc.cl, @profesor.duoc.cl o @gmail.com');
      return;
    }

    // 4. Validar comentario (máx 500)
    if (comentario.length > 500) {
      setError('El comentario no puede superar los 500 caracteres.');
      return;
    }

    // Éxito: Simular envío de mensaje
    setMensajeExito('¡Gracias por comunicarte con nosotros! Te responderemos a la brevedad.');
    
    // Limpiar formulario
    setNombre('');
    setCorreo('');
    setComentario('');
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-12 col-md-7 col-lg-6">
          <div className="card shadow-sm border-0">
            <div className="card-body p-4">

              {/* Título y subtítulo */}
              <div className="text-center mb-4">
                <span style={{ fontSize: '2.5rem' }}>✉️</span>
                <h3 className="fw-bold text-primary mt-2">Formulario de Contacto</h3>
                <p className="text-muted small">
                  ¿Dudas o consultas sobre tu pedido de gas? Escríbenos directamente.
                </p>
              </div>

              {/* Alertas */}
              {error && <div className="alert alert-danger py-2 small">{error}</div>}
              {mensajeExito && <div className="alert alert-success py-2 small">{mensajeExito}</div>}

              <form onSubmit={handleSubmit}>
                
                {/* Nombre */}
                <div className="mb-3">
                  <label className="form-label fw-semibold">Nombre completo *</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="Ej: Juan Pérez"
                    maxLength={100}
                    value={nombre}
                    onChange={(e) => setNombre(e.target.value)}
                  />
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

                {/* Comentario y Contador */}
                <div className="mb-4">
                  <label className="form-label fw-semibold">Mensaje o Consulta *</label>
                  <textarea
                    className="form-control"
                    rows="5"
                    maxLength={500}
                    placeholder="Escribe aquí tu consulta..."
                    value={comentario}
                    onChange={(e) => setComentario(e.target.value)}
                  ></textarea>
                  
                  {/* Contador dinámico */}
                  <div className="text-end mt-1">
                    <small className={`small ${comentario.length >= 480 ? 'text-danger fw-bold' : 'text-muted'}`}>
                      {comentario.length} / 500 caracteres
                    </small>
                  </div>
                </div>

                {/* Botón */}
                <button type="submit" className="btn btn-primary w-100 fw-bold py-2">
                  Enviar Mensaje
                </button>
              </form>

            </div>
          </div>
        </div>
      </div>
    </div>
  );
}