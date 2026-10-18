import { Link } from "react-router-dom";

export default function Blogs() {
  return (
    <div className="container my-5">
      <h2 className="fw-bold mb-1">Nuestro Blog</h2>
      <p className="text-muted mb-4">Consejos, seguridad y ahorro para tu hogar.</p>

      <div className="card mb-4 shadow-sm">
        <div className="card-body">
          <h4 className="card-title text-danger fw-bold">Consejos de seguridad con el gas</h4>
          <p className="card-text">
            ¿Sabías que el gas no tiene olor? Te explicamos por qué huele y qué hacer ante una fuga.
          </p>
          <Link to="/blogs/1" className="btn btn-outline-danger">
            Leer más &rarr;
          </Link>
        </div>
      </div>

      <div className="card mb-4 shadow-sm">
        <div className="card-body">
          <h4 className="card-title text-danger fw-bold">¿Cómo ahorrar gas en invierno?</h4>
          <p className="card-text">
            4 consejos simples para que tu balón de gas dure hasta 30% más.
          </p>
          <Link to="/blogs/2" className="btn btn-outline-danger">
            Leer más &rarr;
          </Link>
        </div>
      </div>
    </div>
  );
}
