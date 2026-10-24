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