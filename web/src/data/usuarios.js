// Lista inicial de usuarios de prueba si el localStorage está vacío
const usuariosIniciales = [
  {
    run: "111111111",
    nombre: "Admin",
    apellidos: "Gas El Volcán",
    correo: "admin@duoc.cl",
    password: "admin",
    tipoUsuario: "Administrador",
    region: "Región de Ñuble",
    comuna: "Chillán",
    direccion: "Bodega Central 100",
    telefono: "911111111"
  },
  {
    run: "222222222",
    nombre: "Carlos",
    apellidos: "Repartidor",
    correo: "vendedor@duoc.cl",
    password: "vende",
    tipoUsuario: "Vendedor",
    region: "Región de Ñuble",
    comuna: "Chillán Viejo",
    direccion: "Calle Los Puelches 45",
    telefono: "922222222"
  },
  {
    run: "190110222",
    nombre: "Juan",
    apellidos: "Perez",
    correo: "cliente@gmail.com",
    password: "1234",
    tipoUsuario: "Cliente",
    region: "Región de Ñuble",
    comuna: "Chillán",
    direccion: "Av Argentina 550",
    telefono: "933333333"
  }
];

// 1. LEER (Read): Trae todos los usuarios del localStorage
export function obtenerUsuarios() {
  const guardados = localStorage.getItem("usuarios");
  if (!guardados) {
    localStorage.setItem("usuarios", JSON.stringify(usuariosIniciales));
    return [...usuariosIniciales];
  }
  return JSON.parse(guardados);
}

// 2. CREAR (Create): Guarda un nuevo usuario
export function registrarUsuario(usuarioNuevo) {
  const lista = obtenerUsuarios();

  // revisar si ya existe el correo o el rut
  const existe = lista.find(u => u.correo === usuarioNuevo.correo || u.run === usuarioNuevo.run);
  if (existe) {
    return false; // ya existe
  }

  lista.push(usuarioNuevo);
  localStorage.setItem("usuarios", JSON.stringify(lista));
  return true;
}

// 3. ELIMINAR (Delete): Borra un usuario por su RUN
export function eliminarUsuario(run) {
  const lista = obtenerUsuarios();
  const nuevaLista = lista.filter(u => u.run !== run);
  localStorage.setItem("usuarios", JSON.stringify(nuevaLista));
}

// 4. LOGIN: Revisa credenciales y guarda sesión
export function loginUsuario(correo, password) {
  const lista = obtenerUsuarios();
  const encontrado = lista.find(u => u.correo.toLowerCase() === correo.toLowerCase() && u.password === password);

  if (encontrado) {
    localStorage.setItem("usuarioActivo", JSON.stringify(encontrado));
    return encontrado;
  }
  return null;
}

// 5. SESIÓN: Trae el usuario conectado (para rellenar el checkout de tus amigos)
export function getUsuarioActivo() {
  const sesion = localStorage.getItem("usuarioActivo");
  return sesion ? JSON.parse(sesion) : null;
}

// 6. Cerrar sesión
export function logout() {
  localStorage.removeItem("usuarioActivo");
}


// 7. PERMISOS: solo Administrador y Vendedor pueden entrar al panel de administración
export function puedeAdministrar(usuario) {
  return Boolean(usuario) && (usuario.tipoUsuario === "Administrador" || usuario.tipoUsuario === "Vendedor");
}