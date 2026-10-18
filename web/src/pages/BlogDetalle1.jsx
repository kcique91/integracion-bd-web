import { Container, Card, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';

export default function BlogDetalle1() {
  return (
    <Container className="my-5" style={{ maxWidth: '800px' }}>
      <Card className="shadow-sm p-4">
        <Card.Body>
          <h1>¿Sabías que el gas no tiene olor?</h1>
          <hr />
          <p>
            El gas licuado de petróleo (GLP) en su estado natural es completamente inodoro e incoloro. 
            El característico olor fuerte es producido por un químico añadido a propósito llamado 
            <strong> Mercaptano</strong>, diseñado para detectar fugas rápidamente y prevenir accidentes.
          </p>
          <p>
            En <strong>Gas El Volcán</strong>, todos nuestros balones pasan por 3 rigurosos controles de seguridad antes de ser distribuidos.
          </p>
          <Button variant="secondary" className="mt-3" as={Link} to="/blogs">
            ← Volver a Blogs
          </Button>
        </Card.Body>
      </Card>
    </Container>
  );
}