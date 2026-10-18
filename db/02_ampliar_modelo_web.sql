-- =====================================================================
-- 02_ampliar_modelo_web.sql
-- Ejecutar conectado como HR, DESPUES de 01_script_base_equipo.sql.
-- Para reconstruir todo desde cero: ejecutar 01, luego 02, 03... en orden.
-- =====================================================================

/* ============ PASO 1: producto_v con los campos de la web ============ */

-- La web tiene precio residencial y precio comercial: renombramos el
-- unico precio actual y agregamos el comercial.
ALTER TABLE producto_v RENAME COLUMN precio TO precio_residencial;

ALTER TABLE producto_v ADD (
    codigo           VARCHAR2(20),
    categoria        VARCHAR2(50),
    descripcion      VARCHAR2(500),
    unidad           VARCHAR2(10),
    precio_comercial NUMBER(10,2),
    stock_critico    NUMBER(6) DEFAULT 0 NOT NULL,
    imagen           VARCHAR2(300)
);

-- Reglas de la web (validacionesProducto.js) repetidas en la base de datos
ALTER TABLE producto_v ADD CONSTRAINT uq_producto_codigo UNIQUE (codigo);

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_categoria CHECK (
    categoria IN ('Cilindros de Gas', 'Reguladores',
                  'Mangueras y Conexiones', 'Accesorios'));

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_unidad CHECK (
    unidad IN ('Unidad', 'Kit'));

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_precios CHECK (
    precio_residencial >= 0 AND precio_comercial >= 0);

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_stock CHECK (
    stock >= 0 AND stock_critico >= 0);
    /* ============ PASO 2A: productos que ya existen en la web ============ */

UPDATE producto_v SET
    codigo = 'CL001', categoria = 'Cilindros de Gas',
    nombre = 'Cilindro GLP 5 kg',
    descripcion = 'Cilindro de gas licuado de petróleo 5 kg. Para uso residencial (cocina, calefacción pequeña)',
    unidad = 'Unidad', precio_residencial = 6500, precio_comercial = 6000,
    stock = 80, stock_critico = 16, imagen = 'cilindro-5kg.jpg'
WHERE id_producto = 1;

UPDATE producto_v SET
    codigo = 'CL002', categoria = 'Cilindros de Gas',
    nombre = 'Cilindro GLP 11 kg',
    descripcion = 'Cilindro estándar doméstico. El más utilizado en hogares chilenos. Compatible con reguladores estándar',
    unidad = 'Unidad', precio_residencial = 12000, precio_comercial = 11000,
    stock = 200, stock_critico = 40, imagen = 'cilindro-11kg.jpg'
WHERE id_producto = 4;

UPDATE producto_v SET
    codigo = 'CL003', categoria = 'Cilindros de Gas',
    nombre = 'Cilindro GLP 15 kg',
    descripcion = 'Cilindro de mayor capacidad para hogares de alto consumo o locales pequeños',
    unidad = 'Unidad', precio_residencial = 16000, precio_comercial = 14500,
    stock = 90, stock_critico = 18, imagen = 'cilindro-15kg.jpg'
WHERE id_producto = 2;

UPDATE producto_v SET
    codigo = 'CL004', categoria = 'Cilindros de Gas',
    nombre = 'Cilindro GLP 45 kg',
    descripcion = 'Cilindro industrial. Uso comercial: restaurantes, talleres, calefacción de locales',
    unidad = 'Unidad', precio_residencial = 45000, precio_comercial = 40000,
    stock = 30, stock_critico = 6, imagen = 'cilindro-45kg.jpg'
WHERE id_producto = 3;

COMMIT;

/* ============ PASO 2B: productos que solo existen en la web ============ */

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (7, 'RG001', 'Reguladores', 'Regulador doméstico estándar',
        'Regulador de 1 etapa para cilindros 5, 11 y 15 kg. Presión de salida 28 mbar',
        'Unidad', 8990, 8200, 45, 9, 'regulador-domestico.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (8, 'RG002', 'Reguladores', 'Regulador de alta presión',
        'Regulador para cocinas industriales o equipos de mayor consumo. Presión regulable',
        'Unidad', 18990, 17000, 12, 3, 'regulador-de-alta-presion.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (9, 'RG003', 'Reguladores', 'Regulador dual (2 salidas)',
        'Permite conectar dos artefactos simultáneamente al mismo cilindro',
        'Unidad', 14990, 13500, 18, 4, 'regulador-dual.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (10, 'MG001', 'Mangueras y Conexiones', 'Manguera gas 1.5m',
        'Manguera flexible homologada. Diámetro interior 9mm. Compatible con reguladores estándar',
        'Unidad', 3990, 3500, 80, 16, 'manguera-gas.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (11, 'MG002', 'Mangueras y Conexiones', 'Manguera gas 3m',
        'Manguera larga para instalaciones donde el artefacto está alejado del cilindro',
        'Unidad', 6990, 6200, 50, 10, 'manguera-gas-3m.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (12, 'MG003', 'Mangueras y Conexiones', 'Abrazadera metálica',
        'Abrazadera de acero para asegurar la conexión manguera-regulador y manguera-artefacto',
        'Unidad', 990, 800, 200, 40, 'abrazadera-metalica.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (13, 'MG004', 'Mangueras y Conexiones',
        'Kit conexión completo (regulador + manguera 1.5m + abrazaderas)',
        'Todo lo necesario para instalar un cilindro nuevo',
        'Kit', 12990, 11500, 25, 5, 'kit-conexion.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (14, 'AC001', 'Accesorios', 'Carro porta cilindro 11/15kg',
        'Carro metálico con ruedas para transportar cilindros dentro del hogar con seguridad',
        'Unidad', 12990, 11000, 20, 4, 'carro-gas.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (15, 'AC002', 'Accesorios', 'Tapa protectora para válvula',
        'Tapa de plástico ABS para proteger la válvula del cilindro durante el transporte',
        'Unidad', 1490, 1200, 60, 12, 'tapa-gas.jpg');

INSERT INTO producto_v (id_producto, codigo, categoria, nombre, descripcion, unidad,
                        precio_residencial, precio_comercial, stock, stock_critico, imagen)
VALUES (16, 'AC003', 'Accesorios', 'Detector de gas a batería',
        'Sensor electroquímico. Alarma sonora y visual ante fuga de gas GLP o metano',
        'Unidad', 19990, 17000, 8, 2, 'detector-gas.jpg');

COMMIT;

/* ============ PASO 2C: balon portatil y recarga pasan al catalogo ============ */

UPDATE producto_v SET
    codigo = 'CL005', categoria = 'Cilindros de Gas',
    nombre = 'Balón portátil 2 kg',
    descripcion = 'Balón portátil de gas licuado 2 kg. Ideal para camping y uso móvil',
    unidad = 'Unidad', precio_comercial = 6300, stock_critico = 4
WHERE id_producto = 5;

UPDATE producto_v SET
    codigo = 'CL006', categoria = 'Cilindros de Gas',
    nombre = 'Recarga balón portátil 2 kg',
    descripcion = 'Recarga de gas licuado para balón portátil de 2 kg',
    unidad = 'Unidad', precio_comercial = 4500, stock_critico = 12
WHERE id_producto = 6;

COMMIT;

/* ============ PASO 2D: codigo de producto obligatorio ============ */

ALTER TABLE producto_v MODIFY (codigo NOT NULL);

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_codigo CHECK (LENGTH(codigo) >= 3);

/* ============ PASO 2E: precio_unitario en detalle_pedido_v ============ */

-- 1. Columna nueva para guardar el precio al que se vendio cada producto
ALTER TABLE detalle_pedido_v ADD (precio_unitario NUMBER(10,2));

-- 2. Pedidos de prueba: se les asigna el precio residencial actual del producto
UPDATE detalle_pedido_v d
SET d.precio_unitario = (SELECT p.precio_residencial
                         FROM producto_v p
                         WHERE p.id_producto = d.id_producto);

-- 3. Recalcular los subtotales con los precios nuevos
UPDATE detalle_pedido_v
SET subtotal = cantidad * precio_unitario;

COMMIT;

-- 4. Desde ahora el precio unitario es obligatorio
ALTER TABLE detalle_pedido_v MODIFY (precio_unitario NOT NULL);

/* ============ PASO 3: usuario_v (usuarios de la web) ============ */

-- Limpieza: permite repetir el script (el 01 no conoce esta tabla)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE usuario_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE usuario_v (
    run              VARCHAR2(9)   PRIMARY KEY,
    nombre           VARCHAR2(50)  NOT NULL,
    apellidos        VARCHAR2(100) NOT NULL,
    correo           VARCHAR2(100) NOT NULL,
    password_hash    VARCHAR2(64)  NOT NULL,
    tipo_usuario     VARCHAR2(15)  NOT NULL,
    region           VARCHAR2(60)  NOT NULL,
    comuna           VARCHAR2(60)  NOT NULL,
    direccion        VARCHAR2(300) NOT NULL,
    telefono         VARCHAR2(15),
    fecha_nacimiento DATE,
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT ck_usuario_run CHECK (REGEXP_LIKE(run, '^[0-9]{7,8}[0-9K]$')),
    CONSTRAINT ck_usuario_correo CHECK (REGEXP_LIKE(correo,
        '^[^@ ]+@(duoc\.cl|profesor\.duoc\.cl|gmail\.com)$', 'i')),
    CONSTRAINT ck_usuario_tipo CHECK (
        tipo_usuario IN ('Administrador', 'Vendedor', 'Cliente'))
);

/* ============ PASO 3B: usuarios iniciales de la web ============ */
-- Las contrasenas estan guardadas como hash bcrypt (admin / vende / 1234)

INSERT INTO usuario_v (run, nombre, apellidos, correo, password_hash, tipo_usuario,
                       region, comuna, direccion, telefono)
VALUES ('111111111', 'Admin', 'Gas El Volcán', 'admin@duoc.cl',
        '$2b$10$t.BwMMsxKhPNPIGafE34y.ok0m0dWPd89dASJZbjgEDidLvG.6uw6',
        'Administrador', 'Región de Ñuble', 'Chillán',
        'Bodega Central 100', '911111111');

INSERT INTO usuario_v (run, nombre, apellidos, correo, password_hash, tipo_usuario,
                       region, comuna, direccion, telefono)
VALUES ('222222222', 'Carlos', 'Repartidor', 'vendedor@duoc.cl',
        '$2b$10$QbA8XtgykY5p2XXwZEEF6ukBcGSa6LP5aHXkoiOPis2C5C.gcNTuu',
        'Vendedor', 'Región de Ñuble', 'Chillán Viejo',
        'Calle Los Puelches 45', '922222222');

INSERT INTO usuario_v (run, nombre, apellidos, correo, password_hash, tipo_usuario,
                       region, comuna, direccion, telefono)
VALUES ('190110222', 'Juan', 'Perez', 'cliente@gmail.com',
        '$2b$10$.8FNJSYfIbsVIIWFiFN35uVTU0Q/L6ev8vRhynb59aQnqU2nQHBnW',
        'Cliente', 'Región de Ñuble', 'Chillán',
        'Av Argentina 550', '933333333');

COMMIT;

        /* ============ PASO 4: enlazar cliente_v con usuario_v ============ */

-- Un cliente puede tener cuenta en la web (run) o no tenerla (run vacio)
ALTER TABLE cliente_v ADD (run VARCHAR2(9));

ALTER TABLE cliente_v ADD CONSTRAINT fk_cliente_usuario
    FOREIGN KEY (run) REFERENCES usuario_v (run);

-- Un usuario de la web corresponde a un solo cliente
ALTER TABLE cliente_v ADD CONSTRAINT uq_cliente_run UNIQUE (run);

-- El usuario de prueba de la web (Juan) tambien pasa a ser cliente,
-- con sus datos copiados desde usuario_v
INSERT INTO cliente_v (id_cliente, nombre, direccion, telefono, email, run)
SELECT 9, nombre || ' ' || apellidos, direccion || ', ' || comuna,
       telefono, correo, run
FROM usuario_v
WHERE run = '190110222';

COMMIT;




