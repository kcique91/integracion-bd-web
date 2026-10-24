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