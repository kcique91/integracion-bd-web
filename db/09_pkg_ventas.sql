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