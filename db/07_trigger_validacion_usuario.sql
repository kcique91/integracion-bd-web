-- =====================================================
-- 07_trigger_validacion_usuario.sql
-- Trigger de FILA: valida los datos de cada usuario antes de guardarlo
-- Ejecutar DESPUES de 01 a 06, con la misma conexion
-- =====================================================

-- BEFORE + FOR EACH ROW: revisa cada fila ANTES de guardarla; si algo es invalido,
-- se rechaza la operacion. Usa fn_validar_run (archivo 03).
CREATE OR REPLACE TRIGGER trg_validar_usuario_v
BEFORE INSERT OR UPDATE ON usuario_v
FOR EACH ROW
BEGIN
   -- 1. Validar el RUN utilizando la funcion fn_validar_run
   IF fn_validar_run(:NEW.run) = 0 THEN
      RAISE_APPLICATION_ERROR(-20050, 'ERROR: El RUN ingresado (' || :NEW.run || ') no es valido segun el algoritmo Modulo 11.');
   END IF;

   -- 2. Validar que la fecha de nacimiento no sea futura
   IF :NEW.fecha_nacimiento > SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20051, 'ERROR: La fecha de nacimiento no puede ser posterior a la fecha actual.');
   END IF;
END;
/
