-- =====================================================
-- 05_package.sql
-- Package pkg_inventario_v (elementos públicos y privados)
-- Ejecutar DESPUES de 01 a 04, con la conexión HR
-- =====================================================

-- ESPECIFICACION: solo lo PUBLICO
CREATE OR REPLACE PACKAGE pkg_inventario_v IS
    -- variable pública (se inicializa en el bloque de inicialización)
    g_fecha_inicio DATE;

    -- consulta el stock de un producto
    FUNCTION stock_disponible (p_id_producto IN NUMBER) RETURN NUMBER;

    -- descuenta unidades del stock de un producto
    PROCEDURE descontar_stock (p_id_producto IN NUMBER, p_cantidad IN NUMBER);

    -- muestra un resumen del inventario por categoría
    PROCEDURE reporte_inventario;
END pkg_inventario_v;
/

-- CUERPO: implementación + elementos PRIVADOS + inicialización
CREATE OR REPLACE PACKAGE BODY pkg_inventario_v IS

    -- ===== ELEMENTOS PRIVADOS (no se pueden usar desde afuera) =====
    g_operaciones NUMBER;

    FUNCTION existe_producto (p_id_producto IN NUMBER) RETURN BOOLEAN
    IS
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM producto_v
         WHERE id_producto = p_id_producto;

        RETURN v_existe > 0;
    END existe_producto;

    PROCEDURE registrar_operacion (p_detalle IN VARCHAR2)
    IS
    BEGIN
        g_operaciones := g_operaciones + 1;
        DBMS_OUTPUT.PUT_LINE('[Operacion ' || g_operaciones || '] ' || p_detalle);
    END registrar_operacion;

    -- ===== ELEMENTOS PUBLICOS =====
    FUNCTION stock_disponible (p_id_producto IN NUMBER) RETURN NUMBER
    IS
        v_stock NUMBER;
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

    PROCEDURE descontar_stock (p_id_producto IN NUMBER, p_cantidad IN NUMBER)
    IS
        v_stock NUMBER;
    BEGIN
        IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'La cantidad debe ser mayor a cero');
        END IF;

        v_stock := stock_disponible(p_id_producto);

        IF v_stock < p_cantidad THEN
            RAISE_APPLICATION_ERROR(-20032, 'Stock insuficiente: disponible ' || v_stock);
        END IF;

        UPDATE producto_v
           SET stock = stock - p_cantidad
         WHERE id_producto = p_id_producto;

        registrar_operacion('Descuento de ' || p_cantidad || ' unidades al producto ' || p_id_producto);
    END descontar_stock;

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