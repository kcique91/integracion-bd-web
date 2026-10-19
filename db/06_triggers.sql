-- =====================================================
-- 06_triggers.sql
-- Triggers a nivel de sentencia y a nivel de fila
-- Ejecutar DESPUES de 01 a 05, con la conexión HR
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
-- sin importar cuántas filas afecte
CREATE OR REPLACE TRIGGER trg_bitacora_producto_v
AFTER INSERT OR UPDATE OR DELETE ON producto_v
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
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
    IF :NEW.precio_unitario IS NULL THEN
        SELECT precio_residencial
          INTO :NEW.precio_unitario
          FROM producto_v
         WHERE id_producto = :NEW.id_producto;
    END IF;

    :NEW.subtotal := :NEW.cantidad * :NEW.precio_unitario;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20040, 'El producto del detalle no existe');
END trg_subtotal_detalle_v;
/