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
