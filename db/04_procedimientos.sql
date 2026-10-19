-- =====================================================
-- 04_procedimientos.sql
-- Procedimientos almacenados (con y sin parámetros)
-- Ejecutar DESPUES de 01, 02 y 03, con la conexión HR
-- =====================================================

-- Procedimiento SIN parámetros (información masiva):
-- muestra un reporte de los productos en nivel de stock crítico
CREATE OR REPLACE PROCEDURE sp_reporte_stock_critico
IS
    v_contador NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PRODUCTOS EN STOCK CRITICO ---');

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
CREATE OR REPLACE PROCEDURE sp_reajustar_precios (
    p_categoria  IN VARCHAR2,
    p_porcentaje IN NUMBER
)
IS
    v_existe NUMBER;
BEGIN
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

    UPDATE producto_v
       SET precio_residencial = ROUND(precio_residencial * (1 + p_porcentaje / 100)),
           precio_comercial   = ROUND(precio_comercial   * (1 + p_porcentaje / 100))
     WHERE UPPER(categoria) = UPPER(p_categoria);

    DBMS_OUTPUT.PUT_LINE('Productos reajustados en ' || p_categoria || ': ' || SQL%ROWCOUNT);
END sp_reajustar_precios;
/