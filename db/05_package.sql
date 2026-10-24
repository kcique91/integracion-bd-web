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