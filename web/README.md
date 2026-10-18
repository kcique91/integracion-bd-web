# Distribuidora Gas El Volcán — Tienda online

Tienda online de una distribuidora de gas de Chillán: catálogo de productos, carrito de compras, registro e inicio de sesión de usuarios y un panel de administración. Es el **Avance 2** del proyecto de *Desarrollo Fullstack II (DSY1104)* en Duoc UC: la tienda del Avance 1 (HTML, CSS y JavaScript) migrada a **React**, con navegación, formularios con validación y pruebas unitarias.

No tiene backend: los datos (usuarios, productos, sesión y carrito) se guardan en el `localStorage` del navegador.

## Tecnologías

| Para qué | Herramienta |
|---|---|
| Interfaz | React 19 |
| Entorno de desarrollo y compilación | Vite 8 |
| Navegación entre páginas | React Router 7 |
| Diseño responsivo y componentes | Bootstrap 5 y React-Bootstrap |
| Pruebas unitarias | Vitest, React Testing Library y jsdom |
| Cobertura de las pruebas | @vitest/coverage-v8 |

## Cómo ejecutarlo

Requiere Node.js (probado con la versión 22).

```bash
npm install          # instala las dependencias
npm run dev          # servidor de desarrollo en http://localhost:5173
npm run build        # compila para producción
npm run lint         # revisa el código con ESLint
npx vitest run       # ejecuta las pruebas una sola vez
npm test             # ejecuta las pruebas en modo observador
npm run coverage     # pruebas + informe de cobertura (carpeta coverage/)
```

## Usuarios de prueba

| Tipo | Correo | Contraseña | Acceso al panel admin |
|---|---|---|---|
| Administrador | admin@duoc.cl | admin | Sí |
| Vendedor | vendedor@duoc.cl | vende | Sí |
| Cliente | cliente@gmail.com | 1234 | No |

Sin sesión iniciada, o con un Cliente, cualquier página `/admin...` redirige al login o al inicio.

## ¿Dónde está...? (mapa del proyecto)

Todo el código está en `src/`.

| Qué buscas | Dónde está |
|---|---|
| Las rutas de la aplicación | `App.jsx` (el `BrowserRouter` está en `main.jsx`) |
| Menú de navegación: sesión, "Ir a Admin", "Cerrar sesión" y contador del carrito | `components/Menu.jsx` |
| Catálogo: lista, detalle y tarjetas de producto | `pages/Productos.jsx`, `pages/ProductoDetalle.jsx`, `components/TarjetaProducto.jsx` |
| Imagen del producto (muestra el ícono de su categoría si no carga) | `components/ImagenProducto.jsx` |
| Productos iniciales | `data/productos.js` |
| Leer, buscar, agregar y editar productos | `services/productosService.js` |
| Carrito: estado, stock y totales | `context/CarritoContext.jsx` y `context/useCarrito.js` |
| Pantalla del carrito | `pages/Carrito.jsx` |
| Inicio de sesión | `pages/Login.jsx` |
| Usuarios y sesión: `loginUsuario`, `registrarUsuario`, `getUsuarioActivo`, `logout`, `puedeAdministrar` | `data/usuarios.js` |
| Registro de usuarios | `pages/Registro.jsx` |
| Validación del RUN (dígito verificador, módulo 11) | `utils/validacionRun.js` |
| Formulario de contacto | `pages/Contacto.jsx` |
| Páginas institucionales | `pages/Nosotros.jsx`, `pages/Blogs.jsx`, `pages/BlogDetalle1.jsx`, `pages/BlogDetalle2.jsx` |
| Panel de administración (7 pantallas) | `pages/admin/` |
| Estructura del panel y protección por tipo de usuario | `components/AdminLayout.jsx` |
| Formularios de producto y de usuario (nuevo y editar) | `components/ProductoForm.jsx` y `components/UsuarioForm.jsx` |
| Validaciones de los formularios del admin | `utils/validacionesProducto.js` y `utils/validacionesUsuario.js` |
| Usuarios del admin: buscar y actualizar | `services/usuariosService.js` |
| Estilos | `App.css`, un `.css` junto a cada componente (`Menu.css`, `TarjetaProducto.css`...) y `styles/admin.css` |
| Pruebas | `test/` |
| Configuración de las pruebas | `../vite.config.js` y `test/setup.js` |

### Cómo se organizan los datos

- `data/` guarda los **datos iniciales** y las funciones básicas de usuarios y sesión.
- `services/` tiene las **operaciones de administración** (buscar, agregar y editar) que usa el panel.
- La tienda y el panel leen los productos desde el mismo lugar (`services/productosService.js`), así que un producto creado o editado en el admin se ve en la tienda.
- Claves de `localStorage`: `productos`, `usuarios`, `usuarioActivo` y `carrito`.

## Pruebas unitarias

Se usa **Vitest** con React Testing Library. Hay **15 pruebas en 6 archivos** dentro de `src/test/`:

| Archivo | Qué prueba | Pruebas |
|---|---|---|
| `acceso.test.js` | Validación del RUN (válido e inválido) e inicio de sesión | 3 |
| `validacionesUsuario.test.js` | Reglas del formulario de usuarios (correo, RUN y uso de un mock de validación) | 3 |
| `CarritoContext.test.jsx` | Agregar productos al carrito y respetar el stock | 2 |
| `TarjetaProducto.test.jsx` | Datos de la tarjeta y botón "Añadir" (con mock del carrito) | 2 |
| `Menu.test.jsx` | Menú con sesión, permisos de "Ir a Admin" y "Cerrar sesión" | 2 |
| `paginas.test.jsx` | Páginas Nosotros y Blogs, y conteos del dashboard del admin | 3 |

El entorno de pruebas se configura en `vite.config.js` (jsdom y cobertura) y en `src/test/setup.js` (limpieza automática entre pruebas y matchers de jest-dom).

## Integrantes

| Integrante | Parte del proyecto |
|---|---|
| Daniel Soto | Catálogo y carrito de compras, menú con sesión, protección del panel admin, integración del proyecto y configuración de las pruebas con Vitest |
| Nicolás Delgado | Inicio de sesión, registro, contacto y validación del RUN |
| Rosa Meza | Páginas institucionales (Nosotros y Blogs) y panel de administración |
| Cristopher Moreno | Formularios del administrador (productos y usuarios) y sus validaciones |

## Alcance y limitaciones

- No hay backend ni base de datos: la persistencia es el `localStorage` del navegador.
- La protección del panel admin se hace en el navegador, sin servidor.
- El botón "Pagar" del carrito está presente, pero todavía no realiza ninguna acción (igual que en el Avance 1).
- Los productos nuevos creados desde el admin no tienen foto: se muestra el ícono de su categoría.
