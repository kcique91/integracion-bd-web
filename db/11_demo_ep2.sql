-- =====================================================
-- 11_demo_ep2.sql
-- Demostracion de los objetos PL/SQL de la solucion
-- Las secciones 1 a 4 siguen el orden del informe y la presentacion
-- (funciones, procedimientos, packages, triggers)
-- Ejecutar DESPUES de 01 a 10, con F5 (Ejecutar script)
-- Todo lo que modifica datos se deshace con ROLLBACK
-- La venta de la seccion 3 sale como pedido 100 solo si las secuencias estan recien creadas:
-- si se repite solo este archivo, correr antes el 08 (recrea las secuencias)
-- =====================================================
SET SERVEROUTPUT ON

PROMPT ============ 1. FUNCIONES ============
PROMPT -- Sin parametros, dentro de un SELECT
SELECT fn_cantidad_stock_critico AS productos_en_stock_critico FROM dual;

PROMPT -- Con parametros, dentro de un SELECT: el precio depende del tipo de cliente
-- Esperado: cliente 7 (comercial) 14500 y cliente 9 (residencial) 16000
SELECT id_cliente, nombre, tipo_cliente,
       fn_precio_producto(2, tipo_cliente) AS precio_15kg
  FROM cliente_v
 WHERE id_cliente IN (7, 9);

PROMPT -- Con parametros, sobre varias filas
SELECT run, nombre, fn_validar_run(run) AS run_valido FROM usuario_v;

PROMPT -- Sin parametros, procesa informacion masiva usando un package
SELECT fn_total_ventas_entregadas AS total_pedidos_entregados FROM dual;

PROMPT ============ 2. PROCEDIMIENTOS ============
PROMPT -- Sin parametros: reporte de productos en stock critico
BEGIN
    sp_reporte_stock_critico;
END;
/

PROMPT -- Con parametros y masivo: reajuste de +10% a toda una categoria
-- Esperado: los 6 cilindros suben 10%; el ROLLBACK final los devuelve a su precio
SELECT codigo, nombre, precio_residencial FROM producto_v
 WHERE categoria = 'Cilindros de Gas' ORDER BY codigo;
BEGIN
    sp_reajustar_precios('Cilindros de Gas', 10);
END;
/
SELECT codigo, nombre, precio_residencial FROM producto_v
 WHERE categoria = 'Cilindros de Gas' ORDER BY codigo;
ROLLBACK;

PROMPT ============ 3. PACKAGES ============
PROMPT -- Elemento PUBLICO usado desde una sentencia SQL
SELECT id_producto, nombre, pkg_inventario_v.stock_disponible(id_producto) AS stock
  FROM producto_v WHERE id_producto IN (1, 10);

PROMPT -- Variable PUBLICA inicializada por el bloque de inicializacion
BEGIN
    DBMS_OUTPUT.PUT_LINE('Package inicializado el: ' ||
        TO_CHAR(pkg_inventario_v.g_fecha_inicio, 'DD/MM/YYYY HH24:MI'));
END;
/

PROMPT -- Venta completa con pkg_ventas_v (cliente 7 = comercial)
-- Esperado: 3 x $6000 + 2 x $3500 = $25000 (precios comerciales)
DECLARE
    v_pedido pedido_v.id_pedido%TYPE;
BEGIN
    pkg_ventas_v.crear_pedido(7, v_pedido);
    pkg_ventas_v.agregar_producto(v_pedido, 1, 3);
    pkg_ventas_v.agregar_producto(v_pedido, 10, 2);
    DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido || ' creado. Total: $' ||
        pkg_gestion_pedidos_v.calcular_total_pedido(v_pedido));
END;
/
SELECT id_pedido, id_producto, cantidad, precio_unitario, subtotal
  FROM detalle_pedido_v WHERE id_pedido = 100;
SELECT id_producto, stock FROM producto_v WHERE id_producto IN (1, 10);
SELECT id_producto, campo, valor_anterior, valor_nuevo
  FROM historial_producto_v ORDER BY id_historial;
ROLLBACK;

PROMPT -- Procedimiento PUBLICO del package: resumen del inventario por categoria
BEGIN
    pkg_inventario_v.reporte_inventario;
END;
/

PROMPT -- Elemento PRIVADO: no se puede usar desde afuera (error esperado PLS-00302)
BEGIN
    pkg_ventas_v.validar_pedido_abierto(1);
END;
/

PROMPT -- Proteccion del stock: intento de vender mas de lo que hay (error esperado ORA-20032)
-- Esperado: ORA-20032 con el stock disponible (2); el stock no cambia y no queda ninguna linea de detalle
DECLARE
    v_pedido pedido_v.id_pedido%TYPE;
BEGIN
    pkg_ventas_v.crear_pedido(7, v_pedido);
    pkg_ventas_v.agregar_producto(v_pedido, 5, 10);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: ' || SQLERRM);
END;
/
SELECT id_producto, stock FROM producto_v WHERE id_producto = 5;
SELECT COUNT(*) AS lineas_de_detalle FROM detalle_pedido_v WHERE id_pedido >= 100;
ROLLBACK;

PROMPT -- crear_pedido con un cliente que no existe (error esperado ORA-20060)
DECLARE
    v_pedido pedido_v.id_pedido%TYPE;
BEGIN
    pkg_ventas_v.crear_pedido(999, v_pedido);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: ' || SQLERRM);
END;
/

PROMPT ============ 4. TRIGGERS ============
PROMPT -- SENTENCIA vs FILA sobre producto_v: un reajuste que afecta a 6 productos
-- Esperado: bitacora +1 (una vez por sentencia); historial +12 (6 productos x 2 precios)
DECLARE
    v_bit_antes NUMBER;
    v_his_antes NUMBER;
    v_bit_desp  NUMBER;
    v_his_desp  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_bit_antes FROM bitacora_producto_v;
    SELECT COUNT(*) INTO v_his_antes FROM historial_producto_v;

    sp_reajustar_precios('Cilindros de Gas', 10);

    SELECT COUNT(*) INTO v_bit_desp FROM bitacora_producto_v;
    SELECT COUNT(*) INTO v_his_desp FROM historial_producto_v;

    DBMS_OUTPUT.PUT_LINE('Filas nuevas en bitacora (trigger de SENTENCIA): ' || (v_bit_desp - v_bit_antes));
    DBMS_OUTPUT.PUT_LINE('Filas nuevas en historial (trigger de FILA):     ' || (v_his_desp - v_his_antes));
END;
/
ROLLBACK;

PROMPT -- FILA sobre detalle_pedido_v: el subtotal se calcula solo
-- Esperado: subtotal = 2 x 6500 = 13000 (no se envia, lo calcula el trigger)
INSERT INTO detalle_pedido_v (id_detalle, id_pedido, id_producto, cantidad, precio_unitario)
VALUES (900, 1, 1, 2, 6500);
SELECT id_detalle, cantidad, precio_unitario, subtotal FROM detalle_pedido_v WHERE id_detalle = 900;
ROLLBACK;

PROMPT -- FILA sobre usuario_v: rechaza un RUN invalido (error esperado ORA-20050)
BEGIN
    INSERT INTO usuario_v (run, nombre, apellidos, correo, password_hash, tipo_usuario, region, comuna, direccion)
    VALUES ('123456789', 'Prueba', 'Test', 'prueba@gmail.com', 'x', 'Cliente', 'R', 'C', 'D');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: ' || SQLERRM);
END;
/
ROLLBACK;