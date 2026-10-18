/**
 * Pruebas unitarias con Vitest para el módulo de Acceso (RUN y login)
 */
import { describe, it, expect, beforeEach } from 'vitest';
import { validarRUN } from '../utils/validacionRun';
import { loginUsuario } from '../data/usuarios';

describe("Acceso: validación de RUN y login (Vitest)", () => {

  // Limpiar el entorno antes de cada prueba
  beforeEach(() => {
    localStorage.clear();
  });

  it("Test 1: [Lógica RUN] Debe validar correctamente un RUN chileno con dígito verificador válido", () => {
    const runValido = "123456785";
    const resultado = validarRUN(runValido);
    expect(resultado).toBe(true);
  });

  it("Test 2: [Lógica RUN] Debe rechazar un RUN chileno con dígito verificador incorrecto", () => {
    const runInvalido = "190110220"; // El dígito correcto es 2, no 0
    const resultado = validarRUN(runInvalido);
    expect(resultado).toBe(false);
  });

  it("Test 3: [Autenticación] Debe iniciar sesión si las credenciales coinciden y guardar la sesión activa", () => {
    // Usuario de prueba precargado: admin@duoc.cl / admin
    const usuario = loginUsuario("admin@duoc.cl", "admin");

    expect(usuario).not.toBeNull();
    expect(usuario.tipoUsuario).toBe("Administrador");

    // La sesión queda guardada en localStorage bajo 'usuarioActivo'
    const sesion = JSON.parse(localStorage.getItem("usuarioActivo"));
    expect(sesion.correo).toBe("admin@duoc.cl");
  });

});