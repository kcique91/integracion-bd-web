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