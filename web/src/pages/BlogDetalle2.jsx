import { Container, Card, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';

export default function BlogDetalle2() {
  return (
    <Container className="my-5" style={{ maxWidth: '800px' }}>
      <Card className="shadow-sm p-4">
        <Card.Body>
          <h1>¿Cómo ahorrar gas en invierno?</h1>
          <p className="text-muted"><small>05/09/2026 - Consejos útiles</small></p>
          <hr />
          <p>En época de invierno el consumo se dispara. Sigue estos sencillos consejos:</p>
          <ul>
            <li><strong>1. Llama siempre azul:</strong> Si presenta tonos amarillos, gasta más gas y es peligrosa.</li>
            <li><strong>2. Duchas de 5 minutos:</strong> El calefont es el artefacto que más gas consume.</li>
            <li><strong>3. No tapes la ventilación:</strong> Permite mantener la seguridad en el hogar.</li>
            <li><strong>4. Pide la recarga con anticipación:</strong> Evita quedarte sin suministro a mitad de uso.</li>
          </ul>
          <Button variant="secondary" className="mt-3" as={Link} to="/blogs">
            ← Volver a Blogs
          </Button>
        </Card.Body>
      </Card>
    </Container>
  );
}