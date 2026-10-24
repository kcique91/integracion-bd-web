/* =====================================================================
   GAS EL VOLCAN - BDY1103 EP2 - Script completo (archivos 01 a 10)
   Construye todo desde cero, en orden: modelo, funciones, procedimientos,
   packages y triggers. Ejecutar completo con F5 (Ejecutar script).
   - Borra y vuelve a crear las tablas *_v: no usar sobre datos que se quieran conservar.
   - La demostracion (11_demo_ep2.sql) va aparte: se ejecuta despues de este script.
   ===================================================================== */

/* #####################################################################
   ARCHIVO 01_script_base_equipo.sql
   ##################################################################### */

/* ===================================================================
   GAS EL VOLCAN - BDY1103 EP1 - Script completo del equipo
   =================================================================== */

SET SERVEROUTPUT ON;


/* ============================= PASO 1: INFRAESTRUCTURA ============================= */

-- Limpieza (permite reejecutar el script sin errores)
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER trg_auditoria_pedido_v';
EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-4080, -4043) THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP PACKAGE pkg_gestion_pedidos_v';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE auditoria_pedido_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE detalle_pedido_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE pedido_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE repartidor_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE producto_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE cliente_v CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Tablas
CREATE TABLE cliente_v (
    id_cliente   NUMBER(6) PRIMARY KEY,
    nombre       VARCHAR2(100) NOT NULL,
    direccion    VARCHAR2(200),
    telefono     VARCHAR2(15),
    email        VARCHAR2(100)
);

CREATE TABLE producto_v (
    id_producto  NUMBER(6) PRIMARY KEY,
    nombre       VARCHAR2(100) NOT NULL,
    tipo_gas     VARCHAR2(50),
    precio       NUMBER(10,2) NOT NULL,
    stock        NUMBER(6) NOT NULL
);

CREATE TABLE repartidor_v (
    id_repartidor NUMBER(6) PRIMARY KEY,
    nombre        VARCHAR2(100) NOT NULL,
    telefono      VARCHAR2(15),
    estado        VARCHAR2(20) DEFAULT 'DISPONIBLE'
);

CREATE TABLE pedido_v (
    id_pedido     NUMBER(6) PRIMARY KEY,
    id_cliente    NUMBER(6) NOT NULL,
    id_repartidor NUMBER(6),
    fecha_pedido  DATE DEFAULT SYSDATE,
    estado        VARCHAR2(20) DEFAULT 'PENDIENTE'
);

CREATE TABLE detalle_pedido_v (
    id_detalle    NUMBER(6) PRIMARY KEY,
    id_pedido     NUMBER(6) NOT NULL,
    id_producto   NUMBER(6) NOT NULL,
    cantidad      NUMBER(4) NOT NULL,
    subtotal      NUMBER(10,2)
);

-- Se crea vacia; el TRIGGER del Paso 7 es lo que la llena
CREATE TABLE auditoria_pedido_v (
    id_auditoria    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido       NUMBER(6) NOT NULL,
    estado_anterior VARCHAR2(20),
    estado_nuevo    VARCHAR2(20),
    fecha_cambio    DATE DEFAULT SYSDATE,
    usuario         VARCHAR2(50)
);

-- Restricciones (FK)
ALTER TABLE pedido_v ADD CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente_v(id_cliente);

ALTER TABLE pedido_v ADD CONSTRAINT fk_pedido_repartidor
    FOREIGN KEY (id_repartidor) REFERENCES repartidor_v(id_repartidor);

ALTER TABLE detalle_pedido_v ADD CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido_v(id_pedido);

ALTER TABLE detalle_pedido_v ADD CONSTRAINT fk_detalle_producto
    FOREIGN KEY (id_producto) REFERENCES producto_v(id_producto);

-- Secuencias: no aplica (auditoria_pedido_v usa GENERATED ALWAYS AS IDENTITY)

-- Datos
INSERT INTO cliente_v VALUES (1, 'Juan Perez', 'Av. Principal 123, Santiago', '912345678', 'juan.perez@mail.com');
INSERT INTO cliente_v VALUES (2, 'Maria Gonzalez', 'Calle Los Aromos 456, Santiago', '923456789', 'maria.gonzalez@mail.com');
INSERT INTO cliente_v VALUES (3, 'Pedro Sanchez', 'Pasaje Las Flores 789, Santiago', '934567890', 'pedro.sanchez@mail.com');
INSERT INTO cliente_v VALUES (4, 'Camila Reyes', 'Los Alerces 234, Providencia', '945000001', 'camila.reyes@mail.com');
INSERT INTO cliente_v VALUES (5, 'Diego Fuentes', 'Camino Real 55, Maipu', '945000002', 'diego.fuentes@mail.com');
INSERT INTO cliente_v VALUES (6, 'Fernanda Ortiz', 'Los Castanos 12, Nunoa', '945000003', 'fernanda.ortiz@mail.com');
INSERT INTO cliente_v VALUES (7, 'Distribuidora El Sol Ltda.', 'Ruta 5 Km 10, Rancagua', '722000004', 'contacto@elsol.cl');
INSERT INTO cliente_v VALUES (8, 'Ignacio Vera', 'Pje. Cordillera 89, Puente Alto', '945000005', 'ignacio.vera@mail.com');

INSERT INTO producto_v VALUES (1, 'Cilindro Gas Licuado 5kg', 'Licuado', 9990, 40);
INSERT INTO producto_v VALUES (2, 'Cilindro Gas Licuado 15kg', 'Licuado', 21990, 25);
INSERT INTO producto_v VALUES (3, 'Cilindro Gas Licuado 45kg', 'Licuado', 54990, 10);
INSERT INTO producto_v VALUES (4, 'Cilindro Gas Licuado 11kg', 'Licuado', 15990, 30);
INSERT INTO producto_v VALUES (5, 'Balon Portatil 2kg', 'Licuado', 6990, 2);
INSERT INTO producto_v VALUES (6, 'Recarga Balon Portatil', 'Licuado', 4990, 60);

INSERT INTO repartidor_v VALUES (1, 'Carlos Munoz', '945678901', 'DISPONIBLE');
INSERT INTO repartidor_v VALUES (2, 'Andrea Rojas', '956789012', 'EN_RUTA');
INSERT INTO repartidor_v VALUES (3, 'Jorge Salinas', '967890123', 'DISPONIBLE');
INSERT INTO repartidor_v VALUES (4, 'Paula Vidal', '978901234', 'EN_RUTA');

INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (1, 1, 1, 'PENDIENTE');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (2, 2, 2, 'EN_CAMINO');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (3, 3, NULL, 'PENDIENTE');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (4, 4, 1, 'ENTREGADO');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (5, 5, 1, 'PENDIENTE');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (6, 6, 2, 'EN_CAMINO');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (7, 7, 4, 'ENTREGADO');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (8, 8, 4, 'PENDIENTE');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (9, 1, NULL, 'PENDIENTE');
INSERT INTO pedido_v (id_pedido, id_cliente, id_repartidor, estado) VALUES (10, 2, 1, 'ENTREGADO');

INSERT INTO detalle_pedido_v VALUES (1, 1, 2, 2, 43980);
INSERT INTO detalle_pedido_v VALUES (2, 1, 1, 1, 9990);
INSERT INTO detalle_pedido_v VALUES (3, 2, 3, 1, 54990);
INSERT INTO detalle_pedido_v VALUES (4, 3, 2, 3, 65970);
INSERT INTO detalle_pedido_v VALUES (5, 4, 1, 2, 19980);
INSERT INTO detalle_pedido_v VALUES (6, 4, 5, 1, 6990);
INSERT INTO detalle_pedido_v VALUES (7, 5, 4, 1, 15990);
INSERT INTO detalle_pedido_v VALUES (8, 5, 6, 3, 14970);
INSERT INTO detalle_pedido_v VALUES (9, 6, 2, 1, 21990);
INSERT INTO detalle_pedido_v VALUES (10, 6, 1, 1, 9990);
INSERT INTO detalle_pedido_v VALUES (11, 7, 3, 2, 109980);
INSERT INTO detalle_pedido_v VALUES (12, 7, 4, 2, 31980);
INSERT INTO detalle_pedido_v VALUES (13, 8, 1, 3, 29970);
INSERT INTO detalle_pedido_v VALUES (14, 9, 6, 2, 9980);
INSERT INTO detalle_pedido_v VALUES (15, 10, 5, 1, 6990);
INSERT INTO detalle_pedido_v VALUES (16, 10, 1, 1, 9990);

COMMIT;


/* ============================= PASO 2: RECORD ============================= */
-- pedido_completo_rec junta en un solo registro los datos de un pedido, su
-- cliente y su repartidor (si tiene). Todos los campos van anclados con
-- %TYPE a la columna real de donde vienen.
DECLARE
    TYPE pedido_completo_rec IS RECORD (
        id_pedido    pedido_v.id_pedido%TYPE,
        nombre_c     cliente_v.nombre%TYPE,
        nombre_r     repartidor_v.nombre%TYPE,
        estado       pedido_v.estado%TYPE,
        fecha_pedido pedido_v.fecha_pedido%TYPE,
        direccion_c  cliente_v.direccion%TYPE
    );
    v_pedido pedido_completo_rec;
BEGIN
    -- JOIN normal con cliente_v (todo pedido tiene cliente obligatorio);
    -- LEFT JOIN con repartidor_v porque un pedido puede no tener
    -- repartidor asignado todavia (id_repartidor NULL)
    SELECT p.id_pedido, c.nombre, r.nombre, p.estado, p.fecha_pedido, c.direccion
    INTO   v_pedido.id_pedido, v_pedido.nombre_c, v_pedido.nombre_r,
           v_pedido.estado, v_pedido.fecha_pedido, v_pedido.direccion_c
    FROM   pedido_v p
    JOIN   cliente_v c ON p.id_cliente = c.id_cliente
    LEFT JOIN repartidor_v r ON p.id_repartidor = r.id_repartidor
    WHERE  p.id_pedido = 9;  -- pedido 9 no tiene repartidor: prueba el LEFT JOIN + NVL

    DBMS_OUTPUT.PUT_LINE('--- Pedido #' || v_pedido.id_pedido || ' ---');
    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_pedido.nombre_c || ' (' || v_pedido.direccion_c || ')');
    -- Si nombre_r vino NULL (LEFT JOIN sin match), NVL lo reemplaza por
    -- un texto legible en vez de mostrar un campo vacio
    DBMS_OUTPUT.PUT_LINE('Repartidor: ' || NVL(v_pedido.nombre_r, 'Sin Asignar'));
    DBMS_OUTPUT.PUT_LINE('Estado: ' || v_pedido.estado);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontro el pedido indicado.');
END;
/


/* ============================= PASO 3: VARRAY ============================= */
-- productos_varray guarda hasta 10 nombres de producto (con su cantidad)
-- para un pedido puntual. Se usa VARCHAR2 (VARCHAR es un tipo en desuso
-- que Oracle recomienda evitar) y se llena con .EXTEND dentro del loop.
DECLARE
    TYPE productos_varray IS VARRAY(10) OF VARCHAR2(100);
    v_productos productos_varray := productos_varray();
    v_contador  NUMBER := 0;

    CURSOR c_productos_pedido IS
        SELECT p.nombre, d.cantidad
        FROM   detalle_pedido_v d
        JOIN   producto_v p ON d.id_producto = p.id_producto
        WHERE  d.id_pedido = 7;
BEGIN
    FOR fila IN c_productos_pedido LOOP
        v_contador := v_contador + 1;
        v_productos.EXTEND;                     -- agranda el VARRAY en 1 espacio
        v_productos(v_contador) := fila.nombre || ' (x' || fila.cantidad || ')';
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Productos del pedido 7:');
    FOR i IN 1..v_productos.COUNT LOOP          -- .COUNT = cuantos elementos tiene realmente
        DBMS_OUTPUT.PUT_LINE('- ' || v_productos(i));
    END LOOP;
END;
/


/* ============================= PASO 4: CURSORES ANIDADOS ============================= */
-- Cursor externo: todos los pedidos de un repartidor.
-- Cursor interno: el detalle de CADA UNO de esos pedidos.
-- Se usa el repartidor 1 (Carlos, 4 pedidos) para una demo mas completa;
-- cambiando v_id_repartidor_buscado a 3 (Jorge) se prueba el caso de un
-- repartidor SIN pedidos asignados (rama del IF final).
DECLARE
    CURSOR c_pedidos_repartidor(p_id_repartidor IN repartidor_v.id_repartidor%TYPE) IS
        SELECT id_pedido, estado
        FROM   pedido_v
        WHERE  id_repartidor = p_id_repartidor;

    CURSOR c_detalle_pedido(p_id_pedido IN pedido_v.id_pedido%TYPE) IS
        SELECT pr.nombre, d.cantidad, d.subtotal
        FROM   detalle_pedido_v d
        JOIN   producto_v pr ON d.id_producto = pr.id_producto
        WHERE  d.id_pedido = p_id_pedido;

    v_nombre_repartidor     repartidor_v.nombre%TYPE;
    v_total_pedido          NUMBER;
    v_pedidos_encontrados   NUMBER := 0;
    v_id_repartidor_buscado repartidor_v.id_repartidor%TYPE := 1; -- Carlos: cambiar a 3 (Jorge) para probar caso vacio
BEGIN
    SELECT nombre INTO v_nombre_repartidor
    FROM   repartidor_v
    WHERE  id_repartidor = v_id_repartidor_buscado;

    -- CHR(10) inserta un salto de linea dentro del mismo PUT_LINE, solo
    -- para separar visualmente el titulo del resto del reporte
    DBMS_OUTPUT.PUT_LINE('Pedidos asignados a ' || v_nombre_repartidor || ':' || CHR(10));

    FOR pedido IN c_pedidos_repartidor(v_id_repartidor_buscado) LOOP
        v_pedidos_encontrados := v_pedidos_encontrados + 1;
        v_total_pedido := 0;

        DBMS_OUTPUT.PUT_LINE('Pedido #' || pedido.id_pedido || ' (' || pedido.estado || ')');

        -- Loop interno: por cada pedido del loop externo, recorre TODO
        -- su detalle y va acumulando el total
        FOR detalle IN c_detalle_pedido(pedido.id_pedido) LOOP
            DBMS_OUTPUT.PUT_LINE('   - ' || detalle.nombre || ' x' || detalle.cantidad || ' = $' || detalle.subtotal);
            v_total_pedido := v_total_pedido + detalle.subtotal;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('   Total pedido: $' || v_total_pedido || CHR(10));
    END LOOP;

    IF v_pedidos_encontrados = 0 THEN
        DBMS_OUTPUT.PUT_LINE(v_nombre_repartidor || ' no tiene pedidos asignados.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe un repartidor con ese ID.');
END;
/


/* ============================= PASO 5: EXCEPCIONES ============================= */
-- Version bloque anonimo, mas simple que el PACKAGE del Paso 6: valida
-- pedido y repartidor con excepciones propias antes de actualizar, y usa
-- SQL%ROWCOUNT para confirmar que el UPDATE si afecto una fila. A
-- diferencia del PACKAGE, esta version no actualiza el estado del
-- repartidor (no lo deja EN_RUTA) - es una version simplificada,
-- enfocada solo en el patron de manejo de excepciones.
-- Con los valores de abajo el bloque SI tiene exito. Para ver cada
-- error, prueba cambiando v_id_pedido a 999 (pedido no encontrado) o
-- v_id_repartidor a 2 (repartidor Andrea, esta EN_RUTA).
DECLARE
    ex_pedido_no_encontrado     EXCEPTION;
    ex_repartidor_no_disponible EXCEPTION;

    v_id_pedido          pedido_v.id_pedido%TYPE := 9;
    v_id_repartidor      repartidor_v.id_repartidor%TYPE := 1;
    v_existe_pedido      NUMBER;
    v_estado_repart      repartidor_v.estado%TYPE;
    v_filas_actualizadas NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe_pedido
    FROM   pedido_v
    WHERE  id_pedido = v_id_pedido;

    IF v_existe_pedido = 0 THEN
        RAISE ex_pedido_no_encontrado;
    END IF;

    SELECT estado INTO v_estado_repart
    FROM   repartidor_v
    WHERE  id_repartidor = v_id_repartidor;

    IF v_estado_repart != 'DISPONIBLE' THEN
        RAISE ex_repartidor_no_disponible;
    END IF;

    UPDATE pedido_v
    SET    id_repartidor = v_id_repartidor,
           estado = 'EN_CAMINO'
    WHERE  id_pedido = v_id_pedido;

    -- SQL%ROWCOUNT: cuantas filas afecto el ULTIMO UPDATE/INSERT/DELETE.
    -- Aqui casi nunca sera 0 (ya validamos arriba que el pedido existe),
    -- pero es buena practica no asumirlo y confirmarlo igual.
    v_filas_actualizadas := SQL%ROWCOUNT;

    IF v_filas_actualizadas = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se pudo actualizar el pedido ' || v_id_pedido);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pedido ' || v_id_pedido || ' asignado correctamente a repartidor ' || v_id_repartidor || '.');
EXCEPTION
    WHEN ex_pedido_no_encontrado THEN
        DBMS_OUTPUT.PUT_LINE('Error: no existe el pedido ' || v_id_pedido);
        ROLLBACK;
    WHEN ex_repartidor_no_disponible THEN
        DBMS_OUTPUT.PUT_LINE('Error: el repartidor no esta disponible (estado: ' || v_estado_repart || ')');
        ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: no existe el repartidor ' || v_id_repartidor);
        ROLLBACK;
    WHEN OTHERS THEN
        -- Red de seguridad final para cualquier error no previsto
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK;
END;
/


/* ============================= PASO 6: PACKAGE ============================= */
-- pkg_gestion_pedidos_v agrupa 3 operaciones de negocio relacionadas con
-- pedidos: calcular el total de un pedido, asignarle un repartidor, y
-- descontar stock de un producto.
--
-- Cada procedimiento declara sus propias excepciones DE FORMA LOCAL
-- (dentro de su propio IS ... BEGIN) y las atrapa en su propio bloque
-- EXCEPTION, convirtiendolas siempre en un error numerado con
-- RAISE_APPLICATION_ERROR. Asi, quien llame a cualquiera de estos
-- procedimientos recibe siempre un mensaje de error claro via SQLERRM,
-- en vez de que la excepcion se propague sin control.

CREATE OR REPLACE PACKAGE pkg_gestion_pedidos_v IS

    FUNCTION calcular_total_pedido(
        p_id_pedido IN pedido_v.id_pedido%TYPE
    ) RETURN NUMBER;

    PROCEDURE asignar_repartidor(
        p_id_pedido     IN pedido_v.id_pedido%TYPE,
        p_id_repartidor IN repartidor_v.id_repartidor%TYPE
    );

    PROCEDURE actualizar_stock(
        p_id_producto IN producto_v.id_producto%TYPE,
        p_cantidad    IN NUMBER
    );

END pkg_gestion_pedidos_v;
/

CREATE OR REPLACE PACKAGE BODY pkg_gestion_pedidos_v IS

    -- Suma los subtotales de detalle_pedido_v para un pedido.
    -- NVL(...,0) evita que un pedido sin detalle (caso raro, pero
    -- posible) devuelva NULL en vez de 0.
    FUNCTION calcular_total_pedido(
        p_id_pedido IN pedido_v.id_pedido%TYPE
    ) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(subtotal), 0) INTO v_total
        FROM   detalle_pedido_v
        WHERE  id_pedido = p_id_pedido;

        RETURN v_total;
    END calcular_total_pedido;

    -- Asigna un repartidor a un pedido, validando que ambos existan y
    -- que el repartidor este DISPONIBLE antes de mover ningun dato.
    PROCEDURE asignar_repartidor(
        p_id_pedido     IN pedido_v.id_pedido%TYPE,
        p_id_repartidor IN repartidor_v.id_repartidor%TYPE
    ) IS
        -- Excepciones LOCALES a este procedimiento
        ex_pedido_no_encontrado     EXCEPTION;
        ex_repartidor_no_disponible EXCEPTION;

        v_estado_repart repartidor_v.estado%TYPE;
        v_existe_pedido NUMBER;
    BEGIN
        -- COUNT(*) en vez de SELECT normal: solo queremos saber SI
        -- existe, no traer datos, asi evitamos depender de NO_DATA_FOUND
        -- para este chequeo puntual
        SELECT COUNT(*) INTO v_existe_pedido
        FROM   pedido_v
        WHERE  id_pedido = p_id_pedido;

        IF v_existe_pedido = 0 THEN
            RAISE ex_pedido_no_encontrado;
        END IF;

        -- Aqui SI usamos SELECT INTO normal: si el repartidor no existe,
        -- queremos que salte la excepcion predefinida NO_DATA_FOUND (se
        -- atrapa mas abajo)
        SELECT estado INTO v_estado_repart
        FROM   repartidor_v
        WHERE  id_repartidor = p_id_repartidor;

        IF v_estado_repart != 'DISPONIBLE' THEN
            RAISE ex_repartidor_no_disponible;
        END IF;

        UPDATE pedido_v
        SET    id_repartidor = p_id_repartidor,
               estado = 'EN_CAMINO'
        WHERE  id_pedido = p_id_pedido;

        UPDATE repartidor_v
        SET    estado = 'EN_RUTA'
        WHERE  id_repartidor = p_id_repartidor;

        COMMIT;
    EXCEPTION
        -- Cada excepcion se convierte en un error numerado propio
        -- (RAISE_APPLICATION_ERROR), para que quien llame al
        -- procedimiento reciba siempre un mensaje claro con SQLERRM, en
        -- vez de un error interno sin explicacion
        WHEN ex_pedido_no_encontrado THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe el pedido N ' || p_id_pedido);
        WHEN ex_repartidor_no_disponible THEN
            RAISE_APPLICATION_ERROR(-20003, 'El repartidor ' || p_id_repartidor ||
                                    ' no esta disponible (estado actual: ' || v_estado_repart || ')');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el repartidor con ID ' || p_id_repartidor);
    END asignar_repartidor;

    -- Descuenta stock de un producto, validando que exista y que alcance
    -- el stock antes de modificar nada.
    PROCEDURE actualizar_stock(
        p_id_producto IN producto_v.id_producto%TYPE,
        p_cantidad    IN NUMBER
    ) IS
        ex_stock_insuficiente EXCEPTION;
        v_stock_actual producto_v.stock%TYPE;
    BEGIN
        SELECT stock INTO v_stock_actual
        FROM   producto_v
        WHERE  id_producto = p_id_producto;

        IF v_stock_actual < p_cantidad THEN
            RAISE ex_stock_insuficiente;
        END IF;

        UPDATE producto_v
        SET    stock = stock - p_cantidad
        WHERE  id_producto = p_id_producto;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'No existe el producto con ID ' || p_id_producto);
        WHEN ex_stock_insuficiente THEN
            RAISE_APPLICATION_ERROR(-20006, 'Stock insuficiente para el producto ' || p_id_producto ||
                                    '. Disponible: ' || v_stock_actual || ', solicitado: ' || p_cantidad);
    END actualizar_stock;

END pkg_gestion_pedidos_v;
/

-- Pruebas del package
BEGIN
    DBMS_OUTPUT.PUT_LINE('Total pedido 7: $' || pkg_gestion_pedidos_v.calcular_total_pedido(7));
END;
/

-- Caso exitoso (pedido 3 sin repartidor; Jorge id=3 esta DISPONIBLE)
BEGIN
    pkg_gestion_pedidos_v.asignar_repartidor(3, 3);
    DBMS_OUTPUT.PUT_LINE('OK: pedido 3 asignado a Jorge.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

-- Caso con error: repartidor NO disponible (pedido 9; Andrea id=2 esta EN_RUTA)
BEGIN
    pkg_gestion_pedidos_v.asignar_repartidor(9, 2);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: ' || SQLERRM);
END;
/

-- Caso con error: stock insuficiente (producto 5, stock=2; pedimos 5)
BEGIN
    pkg_gestion_pedidos_v.actualizar_stock(5, 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: ' || SQLERRM);
END;
/


/* ============================= PASO 7: TRIGGER ============================= */
-- Registra automaticamente en auditoria_pedido_v cada vez que cambia el
-- estado de un pedido, sin importar si el cambio vino de un UPDATE
-- suelto, de un bloque anonimo, o de un procedimiento del PACKAGE.

CREATE OR REPLACE TRIGGER trg_auditoria_pedido_v
    AFTER UPDATE OF estado ON pedido_v
    FOR EACH ROW
    -- OJO: dentro del WHEN, OLD y NEW van SIN los ":" (es la excepcion a
    -- la regla de abajo). El NVL(...,'X') evita comparar contra NULL,
    -- que en Oracle da un resultado "desconocido" (ni verdadero ni
    -- falso) y haria que el trigger no se disparara aunque si hubo un
    -- cambio real.
    WHEN (NVL(OLD.estado, 'X') != NVL(NEW.estado, 'X'))
BEGIN
    -- Dentro del CUERPO del trigger, :OLD y :NEW SI llevan los ":".
    -- USER es una funcion de Oracle que devuelve el usuario conectado.
    INSERT INTO auditoria_pedido_v (id_pedido, estado_anterior, estado_nuevo, usuario)
    VALUES (:NEW.id_pedido, :OLD.estado, :NEW.estado, USER);
END;
/

-- Prueba del trigger: el trigger se creo recien ahora, asi que los
-- UPDATE de los Pasos 5 y 6 (ejecutados antes) no quedaron auditados.
-- Este UPDATE si genera la primera fila en auditoria_pedido_v.
UPDATE pedido_v SET estado = 'EN_CAMINO' WHERE id_pedido = 5;
COMMIT;

SELECT id_pedido, estado_anterior, estado_nuevo, fecha_cambio, usuario
FROM   auditoria_pedido_v
ORDER BY id_auditoria;


/* #####################################################################
   ARCHIVO 02_ampliar_modelo_web.sql
   ##################################################################### */

-- =====================================================================
-- 02_ampliar_modelo_web.sql
-- Que hace: adapta el modelo de EP1 a lo que necesita la tienda web
--   (precio por tipo de cliente, codigo/categoria/imagen, usuarios).
-- Ejecutar con la misma conexion de 01, DESPUES de 01_script_base_equipo.sql.
-- Para reconstruir todo desde cero: ejecutar 01, luego 02, 03... hasta 10, en orden.
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

-- Ultima barrera: el stock nunca puede quedar negativo
-- (pkg_inventario_v lo valida antes y entrega un mensaje claro)
ALTER TABLE producto_v ADD CONSTRAINT ck_producto_stock CHECK (
    stock >= 0 AND stock_critico >= 0);

/* ============ PASO 2A: productos que ya existen en la web ============ */

-- Los productos de EP1 (ids 1 a 4) se igualan al catalogo de la web
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
-- ids 7 a 16: reguladores, mangueras y accesorios del catalogo web

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
-- ids 5 y 6 ya existian en EP1; ahora son productos del catalogo con codigo y categoria

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
-- Ya todos los productos tienen codigo: desde ahora es obligatorio (minimo 3 caracteres)

ALTER TABLE producto_v MODIFY (codigo NOT NULL);

ALTER TABLE producto_v ADD CONSTRAINT ck_producto_codigo CHECK (LENGTH(codigo) >= 3);

/* ============ PASO 2E: precio_unitario en detalle_pedido_v ============ */
-- Cada linea de venta guarda el precio al que se vendio: si el catalogo cambia
-- despues, las ventas ya hechas (y su total) no se alteran

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

-- Cuentas de la web. Las reglas del formulario (RUN, correo, tipo) se repiten aqui;
-- el digito verificador del RUN lo valida el trigger trg_validar_usuario_v (archivo 07)
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

-- Tipo de cliente: define qué lista de precios se le aplica
-- (lo usa fn_precio_producto: RESIDENCIAL -> precio_residencial, COMERCIAL -> precio_comercial)
ALTER TABLE cliente_v ADD (
    tipo_cliente VARCHAR2(12) DEFAULT 'RESIDENCIAL' NOT NULL
);

ALTER TABLE cliente_v ADD CONSTRAINT ck_cliente_tipo CHECK (
    tipo_cliente IN ('RESIDENCIAL', 'COMERCIAL'));

-- La distribuidora del ejemplo de EP1 compra con precio comercial
UPDATE cliente_v SET tipo_cliente = 'COMERCIAL' WHERE id_cliente = 7;

-- El usuario de prueba de la web (Juan) tambien pasa a ser cliente,
-- con sus datos copiados desde usuario_v
INSERT INTO cliente_v (id_cliente, nombre, direccion, telefono, email, run)
SELECT 9, nombre || ' ' || apellidos, direccion || ', ' || comuna,
       telefono, correo, run
FROM usuario_v
WHERE run = '190110222';

COMMIT;

-- Los cambios de tabla invalidan el package de EP1: se recompila
ALTER PACKAGE pkg_gestion_pedidos_v COMPILE BODY;


/* #####################################################################
   ARCHIVO 03_funciones.sql
   ##################################################################### */

-- =====================================================
-- 03_funciones.sql
-- Funciones almacenadas (con y sin parámetros)
-- Ejecutar DESPUES de 01 y 02, con la misma conexión
-- =====================================================

-- Función SIN parámetros:
-- cuenta los productos cuyo stock está en el nivel crítico o por debajo
-- Uso: SELECT fn_cantidad_stock_critico FROM dual;
CREATE OR REPLACE FUNCTION fn_cantidad_stock_critico
RETURN NUMBER
IS
    v_cantidad NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_cantidad
      FROM producto_v
     WHERE stock <= stock_critico;

    RETURN v_cantidad;
END fn_cantidad_stock_critico;
/

-- Función CON parámetros:
-- devuelve el precio de un producto según el tipo de cliente
-- Regla de negocio central: el mismo producto tiene precio residencial o comercial.
-- La usa pkg_ventas_v al agregar un producto a un pedido.
-- Errores: -20010 producto inexistente, -20011 tipo de cliente no válido
CREATE OR REPLACE FUNCTION fn_precio_producto (
    p_id_producto  IN producto_v.id_producto%TYPE,
    p_tipo_cliente IN cliente_v.tipo_cliente%TYPE
)
RETURN producto_v.precio_residencial%TYPE
IS
    v_precio producto_v.precio_residencial%TYPE;
BEGIN
    SELECT CASE UPPER(p_tipo_cliente)
               WHEN 'RESIDENCIAL' THEN precio_residencial
               WHEN 'COMERCIAL'   THEN precio_comercial
           END
      INTO v_precio
      FROM producto_v
     WHERE id_producto = p_id_producto;

    -- el CASE devuelve NULL cuando el tipo no es RESIDENCIAL ni COMERCIAL
    IF v_precio IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Tipo de cliente no valido: use RESIDENCIAL o COMERCIAL');
    END IF;

    RETURN v_precio;
EXCEPTION
    -- SELECT INTO sin filas: el producto no existe
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'El producto no existe');
END fn_precio_producto;
/

-- Función CON parámetros:
-- valida el dígito verificador de un RUN (módulo 11)
-- devuelve 1 si es válido y 0 si no lo es
-- La usa el trigger trg_validar_usuario_v (archivo 07)
CREATE OR REPLACE FUNCTION fn_validar_run (
    p_run IN usuario_v.run%TYPE
)
RETURN NUMBER
IS
    v_cuerpo        VARCHAR2(20);
    v_dv_ingresado  VARCHAR2(1);
    v_dv_calculado  VARCHAR2(1);
    v_suma          NUMBER := 0;
    v_multiplicador NUMBER := 2;
    v_resto         NUMBER;
BEGIN
    IF p_run IS NULL OR LENGTH(p_run) < 2 THEN
        RETURN 0;
    END IF;

    v_cuerpo       := SUBSTR(p_run, 1, LENGTH(p_run) - 1);
    v_dv_ingresado := UPPER(SUBSTR(p_run, -1));

    IF NOT REGEXP_LIKE(v_cuerpo, '^[0-9]+$') THEN
        RETURN 0;
    END IF;

    -- Se recorre el cuerpo de derecha a izquierda con los factores 2,3,4,5,6,7,2,3...
    FOR i IN REVERSE 1 .. LENGTH(v_cuerpo) LOOP
        v_suma := v_suma + TO_NUMBER(SUBSTR(v_cuerpo, i, 1)) * v_multiplicador;
        v_multiplicador := v_multiplicador + 1;
        IF v_multiplicador > 7 THEN
            v_multiplicador := 2;
        END IF;
    END LOOP;

    -- dígito esperado: si el cálculo da 11 es 0, si da 10 es K, en otro caso el mismo número
    v_resto := 11 - MOD(v_suma, 11);

    v_dv_calculado := CASE v_resto
                          WHEN 11 THEN '0'
                          WHEN 10 THEN 'K'
                          ELSE TO_CHAR(v_resto)
                      END;

    IF v_dv_calculado = v_dv_ingresado THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END fn_validar_run;
/

-- Función SIN parámetros (información masiva):
-- suma el total de todos los pedidos ENTREGADOS
-- reutiliza la función calcular_total_pedido del package
CREATE OR REPLACE FUNCTION fn_total_ventas_entregadas
RETURN NUMBER
IS
    v_total NUMBER := 0;
BEGIN
    FOR r IN (SELECT id_pedido
                FROM pedido_v
               WHERE estado = 'ENTREGADO') LOOP
        v_total := v_total + pkg_gestion_pedidos_v.calcular_total_pedido(r.id_pedido);
    END LOOP;

    RETURN v_total;
END fn_total_ventas_entregadas;
/


/* #####################################################################
   ARCHIVO 04_procedimientos.sql
   ##################################################################### */

-- =====================================================
-- 04_procedimientos.sql
-- Procedimientos almacenados (con y sin parámetros)
-- Ejecutar DESPUES de 01, 02 y 03, con la misma conexión
-- =====================================================

-- Procedimiento SIN parámetros (información masiva):
-- muestra un reporte de los productos en nivel de stock crítico
-- Uso: EXEC sp_reporte_stock_critico   (con SET SERVEROUTPUT ON)
CREATE OR REPLACE PROCEDURE sp_reporte_stock_critico
IS
    v_contador NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PRODUCTOS EN STOCK CRITICO ---');

    -- faltan = unidades necesarias para superar el nivel crítico
    FOR r IN (SELECT codigo, nombre, stock, stock_critico
                FROM producto_v
               WHERE stock <= stock_critico
               ORDER BY codigo) LOOP
        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE(r.codigo || ' - ' || r.nombre ||
                             ' | stock: ' || r.stock ||
                             ' | critico: ' || r.stock_critico ||
                             ' | faltan: ' || (r.stock_critico - r.stock + 1));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total de productos en critico: ' || v_contador);
END sp_reporte_stock_critico;
/

-- Procedimiento CON parámetros (información masiva):
-- reajusta los precios de todos los productos de una categoría
-- p_porcentaje: 10 sube 10%, -5 baja 5%
-- Un solo UPDATE reajusta toda la categoría. No hace COMMIT: lo decide quien la llama.
-- Cada precio que cambia queda registrado por trg_historial_producto_v (archivo 10).
CREATE OR REPLACE PROCEDURE sp_reajustar_precios (
    p_categoria  IN producto_v.categoria%TYPE,
    p_porcentaje IN NUMBER
)
IS
    v_existe NUMBER;
BEGIN
    -- Validaciones: porcentaje razonable (-20021) y categoría existente (-20020)
    IF p_porcentaje IS NULL OR p_porcentaje <= -50 OR p_porcentaje > 100 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Porcentaje no valido: debe ser mayor a -50 y hasta 100');
    END IF;

    SELECT COUNT(*)
      INTO v_existe
      FROM producto_v
     WHERE UPPER(categoria) = UPPER(p_categoria);

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'La categoria no existe: ' || p_categoria);
    END IF;

    -- Proceso masivo: ambos precios de todos los productos de la categoría
    UPDATE producto_v
       SET precio_residencial = ROUND(precio_residencial * (1 + p_porcentaje / 100)),
           precio_comercial   = ROUND(precio_comercial   * (1 + p_porcentaje / 100))
     WHERE UPPER(categoria) = UPPER(p_categoria);

    -- SQL%ROWCOUNT = cantidad de productos afectados por el UPDATE
    DBMS_OUTPUT.PUT_LINE('Productos reajustados en ' || p_categoria || ': ' || SQL%ROWCOUNT);
END sp_reajustar_precios;
/


/* #####################################################################
   ARCHIVO 05_package.sql
   ##################################################################### */

-- =====================================================
-- 05_package.sql
-- Package pkg_inventario_v (elementos públicos y privados)
-- Reglas del stock en un solo lugar: consultar, descontar y reportar
-- Ejecutar DESPUES de 01 a 04, con la misma conexión
-- =====================================================

-- ESPECIFICACION: solo lo PUBLICO
CREATE OR REPLACE PACKAGE pkg_inventario_v IS
    -- variable pública (se inicializa en el bloque de inicialización)
    g_fecha_inicio DATE;

    -- consulta el stock de un producto
    FUNCTION stock_disponible (p_id_producto IN producto_v.id_producto%TYPE)
        RETURN producto_v.stock%TYPE;

    -- descuenta unidades del stock de un producto
    PROCEDURE descontar_stock (p_id_producto IN producto_v.id_producto%TYPE,
                               p_cantidad    IN producto_v.stock%TYPE);

    -- muestra un resumen del inventario por categoría
    PROCEDURE reporte_inventario;
END pkg_inventario_v;
/

-- CUERPO: implementación + elementos PRIVADOS + inicialización
CREATE OR REPLACE PACKAGE BODY pkg_inventario_v IS

    -- ===== ELEMENTOS PRIVADOS (no se pueden usar desde afuera) =====
    -- contador de operaciones de la sesión (se pone en 0 en el bloque final del package)
    g_operaciones NUMBER;

    -- valida que el producto exista (la usa stock_disponible)
    FUNCTION existe_producto (p_id_producto IN producto_v.id_producto%TYPE)
        RETURN BOOLEAN
    IS
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM producto_v
         WHERE id_producto = p_id_producto;

        RETURN v_existe > 0;
    END existe_producto;

    -- deja constancia en pantalla (DBMS_OUTPUT) de cada operación y la cuenta
    PROCEDURE registrar_operacion (p_detalle IN VARCHAR2)
    IS
    BEGIN
        g_operaciones := g_operaciones + 1;
        DBMS_OUTPUT.PUT_LINE('[Operacion ' || g_operaciones || '] ' || p_detalle);
    END registrar_operacion;

    -- ===== ELEMENTOS PUBLICOS =====
    -- stock_disponible también sirve dentro de un SELECT (ver 11_demo_ep2.sql)
    FUNCTION stock_disponible (p_id_producto IN producto_v.id_producto%TYPE)
        RETURN producto_v.stock%TYPE
    IS
        v_stock producto_v.stock%TYPE;
    BEGIN
        IF NOT existe_producto(p_id_producto) THEN
            RAISE_APPLICATION_ERROR(-20030, 'El producto no existe');
        END IF;

        SELECT stock
          INTO v_stock
          FROM producto_v
         WHERE id_producto = p_id_producto;

        RETURN v_stock;
    END stock_disponible;

    -- La usa pkg_ventas_v al vender. No hace COMMIT.
    -- El UPDATE condicional protege el stock aun con compras simultáneas: si dos pedidos
    -- compiten por la última unidad, uno descuenta y el otro recibe -20032.
    PROCEDURE descontar_stock (p_id_producto IN producto_v.id_producto%TYPE,
                               p_cantidad    IN producto_v.stock%TYPE)
    IS
        v_stock producto_v.stock%TYPE;
    BEGIN
        IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'La cantidad debe ser mayor a cero');
        END IF;

        -- Una sola sentencia: descuenta solo si alcanza el stock
        UPDATE producto_v
           SET stock = stock - p_cantidad
         WHERE id_producto = p_id_producto
           AND stock >= p_cantidad;

        IF SQL%ROWCOUNT = 0 THEN
            -- No se descontó nada: el producto no existe o falta stock.
            -- stock_disponible lanza -20030 si el producto no existe.
            v_stock := stock_disponible(p_id_producto);
            RAISE_APPLICATION_ERROR(-20032, 'Stock insuficiente: disponible ' || v_stock);
        END IF;

        registrar_operacion('Descuento de ' || p_cantidad || ' unidades al producto ' || p_id_producto);
    END descontar_stock;

    -- resumen de productos y unidades por categoría (GROUP BY)
    PROCEDURE reporte_inventario
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- INVENTARIO POR CATEGORIA ---');

        FOR r IN (SELECT categoria,
                         COUNT(*)   AS productos,
                         SUM(stock) AS unidades
                    FROM producto_v
                   GROUP BY categoria
                   ORDER BY categoria) LOOP
            DBMS_OUTPUT.PUT_LINE(r.categoria || ' | productos: ' || r.productos ||
                                 ' | unidades: ' || r.unidades);
        END LOOP;

        registrar_operacion('Reporte de inventario generado');
    END reporte_inventario;

-- ===== BLOQUE DE INICIALIZACION ("constructor") =====
-- se ejecuta una sola vez, la primera vez que se usa el package en la sesión
BEGIN
    g_fecha_inicio := SYSDATE;
    g_operaciones  := 0;
END pkg_inventario_v;
/


/* #####################################################################
   ARCHIVO 06_triggers.sql
   ##################################################################### */

-- =====================================================
-- 06_triggers.sql
-- Triggers a nivel de sentencia y a nivel de fila
-- Ejecutar DESPUES de 01 a 05, con la misma conexión
-- =====================================================

-- Limpieza para poder re-ejecutar el archivo
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE bitacora_producto_v PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Tabla donde se guarda la bitácora de cambios en productos
CREATE TABLE bitacora_producto_v (
    id_bitacora     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    operacion       VARCHAR2(10) NOT NULL,
    usuario         VARCHAR2(50) NOT NULL,
    fecha_operacion DATE DEFAULT SYSDATE NOT NULL
);

-- Trigger a nivel de SENTENCIA:
-- se dispara una sola vez por cada INSERT, UPDATE o DELETE sobre producto_v,
-- sin importar cuántas filas afecte (incluso si no afecta ninguna).
-- Contraste: trg_historial_producto_v (archivo 10) es de FILA y registra producto por producto.
CREATE OR REPLACE TRIGGER trg_bitacora_producto_v
AFTER INSERT OR UPDATE OR DELETE ON producto_v
DECLARE
    v_operacion bitacora_producto_v.operacion%TYPE;
BEGIN
    -- INSERTING / UPDATING indican qué sentencia disparó el trigger
    IF INSERTING THEN
        v_operacion := 'INSERT';
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
    ELSE
        v_operacion := 'DELETE';
    END IF;

    INSERT INTO bitacora_producto_v (operacion, usuario)
    VALUES (v_operacion, USER);
END trg_bitacora_producto_v;
/

-- Trigger a nivel de FILA:
-- se dispara una vez por cada fila insertada o modificada en detalle_pedido_v
-- calcula el subtotal y, si falta, toma el precio unitario del producto
CREATE OR REPLACE TRIGGER trg_subtotal_detalle_v
BEFORE INSERT OR UPDATE OF cantidad, precio_unitario ON detalle_pedido_v
FOR EACH ROW
BEGIN
    -- NEW = la fila que se está por guardar. Si no trae precio, se toma el residencial
    -- (pkg_ventas_v siempre lo envía, según el tipo de cliente)
    IF :NEW.precio_unitario IS NULL THEN
        SELECT precio_residencial
          INTO :NEW.precio_unitario
          FROM producto_v
         WHERE id_producto = :NEW.id_producto;
    END IF;

    -- el subtotal siempre lo calcula el trigger, nunca se digita
    :NEW.subtotal := :NEW.cantidad * :NEW.precio_unitario;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20040, 'El producto del detalle no existe');
END trg_subtotal_detalle_v;
/


/* #####################################################################
   ARCHIVO 07_trigger_validacion_usuario.sql
   ##################################################################### */

-- =====================================================
-- 07_trigger_validacion_usuario.sql
-- Trigger de FILA: valida los datos de cada usuario antes de guardarlo
-- Ejecutar DESPUES de 01 a 06, con la misma conexion
-- =====================================================

-- BEFORE + FOR EACH ROW: revisa cada fila ANTES de guardarla; si algo es invalido,
-- se rechaza la operacion. Usa fn_validar_run (archivo 03).
CREATE OR REPLACE TRIGGER trg_validar_usuario_v
BEFORE INSERT OR UPDATE ON usuario_v
FOR EACH ROW
BEGIN
   -- 1. Validar el RUN utilizando la funcion fn_validar_run
   IF fn_validar_run(:NEW.run) = 0 THEN
      RAISE_APPLICATION_ERROR(-20050, 'ERROR: El RUN ingresado (' || :NEW.run || ') no es valido segun el algoritmo Modulo 11.');
   END IF;

   -- 2. Validar que la fecha de nacimiento no sea futura
   IF :NEW.fecha_nacimiento > SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20051, 'ERROR: La fecha de nacimiento no puede ser posterior a la fecha actual.');
   END IF;
END;
/


/* #####################################################################
   ARCHIVO 08_modelo_ventas.sql
   ##################################################################### */

-- =====================================================
-- 08_modelo_ventas.sql
-- Secuencias y tabla de historial para el flujo de venta
-- Ejecutar DESPUES de 01 a 07, con la misma conexión
-- =====================================================

-- Limpieza para poder re-ejecutar el archivo
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE historial_producto_v PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_pedido_v';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_detalle_pedido_v';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

-- Secuencias: pedido_v y detalle_pedido_v no generan su propio id.
-- Parten en 100 para no chocar con los datos que ya existen.
-- Un ROLLBACK no devuelve el numero usado: pueden quedar saltos en los ids, es normal.
CREATE SEQUENCE seq_pedido_v         START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_detalle_pedido_v START WITH 100 INCREMENT BY 1 NOCACHE;

-- Historial: una fila por cada campo de producto que cambia (stock o precios)
-- La llena el trigger trg_historial_producto_v (archivo 10)
CREATE TABLE historial_producto_v (
    id_historial   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto    NUMBER(6)    NOT NULL,
    campo          VARCHAR2(30) NOT NULL,
    valor_anterior NUMBER(10,2),
    valor_nuevo    NUMBER(10,2),
    usuario        VARCHAR2(50) NOT NULL,
    fecha_cambio   DATE         DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_historial_producto FOREIGN KEY (id_producto) REFERENCES producto_v (id_producto),
    CONSTRAINT ck_historial_campo CHECK (campo IN ('STOCK', 'PRECIO_RESIDENCIAL', 'PRECIO_COMERCIAL'))
);


/* #####################################################################
   ARCHIVO 09_pkg_ventas.sql
   ##################################################################### */

-- =====================================================
-- 09_pkg_ventas.sql
-- Package pkg_ventas_v: flujo de venta (pedido y detalle)
-- Une las piezas: precio segun tipo de cliente (fn_precio_producto, 03) +
-- descuento de stock (pkg_inventario_v, 05) + subtotal (trigger, 06)
-- Ejecutar DESPUES de 01 a 08, con la misma conexión
-- Ningun procedimiento hace COMMIT: lo decide quien los llama
-- =====================================================

-- ESPECIFICACION: solo lo PUBLICO
CREATE OR REPLACE PACKAGE pkg_ventas_v IS
    -- abre un pedido PENDIENTE para un cliente y devuelve su id
    PROCEDURE crear_pedido (p_id_cliente IN  cliente_v.id_cliente%TYPE,
                            p_id_pedido  OUT pedido_v.id_pedido%TYPE);

    -- agrega un producto al pedido: precio segun tipo de cliente,
    -- descuenta stock y registra la linea de detalle
    PROCEDURE agregar_producto (p_id_pedido   IN pedido_v.id_pedido%TYPE,
                                p_id_producto IN producto_v.id_producto%TYPE,
                                p_cantidad    IN detalle_pedido_v.cantidad%TYPE);
END pkg_ventas_v;
/

-- CUERPO: implementacion + elementos PRIVADOS
CREATE OR REPLACE PACKAGE BODY pkg_ventas_v IS

    -- ===== ELEMENTOS PRIVADOS (no se pueden usar desde afuera) =====
    -- un pedido admite cambios solo si existe y esta PENDIENTE
    PROCEDURE validar_pedido_abierto (p_id_pedido IN pedido_v.id_pedido%TYPE)
    IS
        v_estado pedido_v.estado%TYPE;
    BEGIN
        SELECT estado
          INTO v_estado
          FROM pedido_v
         WHERE id_pedido = p_id_pedido;

        IF NVL(v_estado, 'X') != 'PENDIENTE' THEN
            RAISE_APPLICATION_ERROR(-20062, 'El pedido ' || p_id_pedido ||
                ' ya no admite cambios (estado ' || v_estado || ')');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20061, 'El pedido ' || p_id_pedido || ' no existe');
    END validar_pedido_abierto;

    -- ===== ELEMENTOS PUBLICOS =====
    PROCEDURE crear_pedido (p_id_cliente IN  cliente_v.id_cliente%TYPE,
                            p_id_pedido  OUT pedido_v.id_pedido%TYPE)
    IS
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM cliente_v
         WHERE id_cliente = p_id_cliente;

        IF v_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20060, 'El cliente ' || p_id_cliente || ' no existe');
        END IF;

        -- el id sale de la secuencia creada en 08
        p_id_pedido := seq_pedido_v.NEXTVAL;

        -- fecha y estado toman sus valores por defecto (SYSDATE y PENDIENTE)
        INSERT INTO pedido_v (id_pedido, id_cliente)
        VALUES (p_id_pedido, p_id_cliente);
    END crear_pedido;

    PROCEDURE agregar_producto (p_id_pedido   IN pedido_v.id_pedido%TYPE,
                                p_id_producto IN producto_v.id_producto%TYPE,
                                p_cantidad    IN detalle_pedido_v.cantidad%TYPE)
    IS
        v_tipo   cliente_v.tipo_cliente%TYPE;
        v_precio detalle_pedido_v.precio_unitario%TYPE;
    BEGIN
        validar_pedido_abierto(p_id_pedido);

        -- el tipo del cliente del pedido define la lista de precios
        SELECT c.tipo_cliente
          INTO v_tipo
          FROM pedido_v p
          JOIN cliente_v c ON c.id_cliente = p.id_cliente
         WHERE p.id_pedido = p_id_pedido;

        -- primero el precio (falla si el producto no existe) y despues el stock
        -- si el stock no alcanza, descontar_stock lanza -20032 y no se inserta el detalle
        v_precio := fn_precio_producto(p_id_producto, v_tipo);
        pkg_inventario_v.descontar_stock(p_id_producto, p_cantidad);

        -- el subtotal lo calcula el trigger trg_subtotal_detalle_v
        INSERT INTO detalle_pedido_v (id_detalle, id_pedido, id_producto, cantidad, precio_unitario)
        VALUES (seq_detalle_pedido_v.NEXTVAL, p_id_pedido, p_id_producto, p_cantidad, v_precio);
    END agregar_producto;

END pkg_ventas_v;
/


/* #####################################################################
   ARCHIVO 10_trigger_historial.sql
   ##################################################################### */

-- =====================================================
-- 10_trigger_historial.sql
-- Trigger de FILA: historial de cambios de stock y precios
-- Ejecutar DESPUES de 01 a 09, con la misma conexión
-- =====================================================

-- Cada vez que cambia el stock o un precio, deja una fila por campo cambiado
-- (valor anterior, valor nuevo, usuario y fecha): permite saber quien cambio que.
-- Es de FILA (FOR EACH ROW): se ejecuta una vez por cada producto modificado.
-- OLD = valor antes del UPDATE, NEW = valor despues.
-- AFTER UPDATE OF: solo actua si se modifican esas columnas.
CREATE OR REPLACE TRIGGER trg_historial_producto_v
AFTER UPDATE OF stock, precio_residencial, precio_comercial ON producto_v
FOR EACH ROW
BEGIN
    -- se compara OLD con NEW para registrar solo lo que realmente cambio
    IF :NEW.stock != :OLD.stock THEN
        INSERT INTO historial_producto_v (id_producto, campo, valor_anterior, valor_nuevo, usuario)
        VALUES (:NEW.id_producto, 'STOCK', :OLD.stock, :NEW.stock, USER);
    END IF;

    IF :NEW.precio_residencial != :OLD.precio_residencial THEN
        INSERT INTO historial_producto_v (id_producto, campo, valor_anterior, valor_nuevo, usuario)
        VALUES (:NEW.id_producto, 'PRECIO_RESIDENCIAL', :OLD.precio_residencial, :NEW.precio_residencial, USER);
    END IF;

    -- el precio comercial puede ser NULL, por eso se compara con NVL
    IF NVL(:NEW.precio_comercial, -1) != NVL(:OLD.precio_comercial, -1) THEN
        INSERT INTO historial_producto_v (id_producto, campo, valor_anterior, valor_nuevo, usuario)
        VALUES (:NEW.id_producto, 'PRECIO_COMERCIAL', :OLD.precio_comercial, :NEW.precio_comercial, USER);
    END IF;
END trg_historial_producto_v;
/


/* ============ VERIFICACION FINAL ============ */
-- No debe devolver filas: significa que todos los objetos compilaron (VALID)
SELECT object_name, object_type, status
  FROM user_objects
 WHERE status != 'VALID';
