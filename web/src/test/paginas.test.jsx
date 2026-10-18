// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import * as matchers from '@testing-library/jest-dom/matchers';

// Extiende los matchers de Vitest para usar .toBeInTheDocument()
expect.extend(matchers);

import Nosotros from '../pages/Nosotros';
import AdminHome from '../pages/admin/AdminHome';
import Blogs from '../pages/Blogs';
import { productos } from '../data/productos';
import * as usuariosData from '../data/usuarios';

describe('Pruebas de Nosotros, Blogs y el dashboard del admin', () => {
  // Prueba 1: Verifica la página Nosotros
  it('debe renderizar la página Nosotros con su título y fundadores', () => {
    render(
      <MemoryRouter>
        <Nosotros />
      </MemoryRouter>
    );
    expect(screen.getByText(/Nuestra Historia/i)).toBeInTheDocument();
    expect(screen.getByText(/Nuestros Fundadores/i)).toBeInTheDocument();
  });

  // Prueba 2: Verifica que AdminHome muestra las cantidades dinámicas (14 productos y 3 usuarios)
  it('debe mostrar los conteos dinámicos en el AdminHome', () => {
    // El panel admin está protegido: se simula un administrador con sesión iniciada
    localStorage.setItem('usuarioActivo', JSON.stringify({ nombre: 'Admin', tipoUsuario: 'Administrador' }));
    render(
      <MemoryRouter>
        <AdminHome />
      </MemoryRouter>
    );
    const totalProductos = productos.length;
    
    // Obtiene la lista de usuarios según la exportación del archivo
    const usuariosList = usuariosData.usuariosPrueba || usuariosData.usuarios || (typeof usuariosData.obtenerUsuarios === 'function' ? usuariosData.obtenerUsuarios() : []);
    const totalUsuarios = usuariosList.length;

    expect(screen.getByText(String(totalProductos))).toBeInTheDocument();
    expect(screen.getByText(String(totalUsuarios))).toBeInTheDocument();
  });

  // Prueba 3: Verifica el renderizado de la vista de Blogs
  it('debe renderizar la página de Blogs', () => {
    render(
      <MemoryRouter>
        <Blogs />
      </MemoryRouter>
    );
    expect(screen.getByText(/Nuestro Blog/i)).toBeInTheDocument();
  });
});