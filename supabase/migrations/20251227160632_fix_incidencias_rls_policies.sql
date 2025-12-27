/*
  # Arreglar políticas RLS de incidencias

  1. Cambios
    - Elimina las políticas antiguas que usaban email_inquilino
    - Crea nuevas políticas que usan propiedad_id directamente
    - Esto es más eficiente y correcto arquitecturalmente
  
  2. Seguridad
    - Caseros ven incidencias solo de sus propiedades (via propiedad_id)
    - Inquilinos ven solo sus propias incidencias (via user_id)
*/

-- Eliminar políticas antiguas de caseros
DROP POLICY IF EXISTS "Caseros pueden ver incidencias de sus propiedades" ON incidencias;
DROP POLICY IF EXISTS "Caseros pueden actualizar sus incidencias" ON incidencias;

-- Nueva política para que caseros vean incidencias usando propiedad_id
CREATE POLICY "Caseros pueden ver incidencias de sus propiedades"
  ON incidencias FOR SELECT
  TO authenticated
  USING (
    propiedad_id IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM propiedades p
      WHERE p.id = incidencias.propiedad_id
      AND p.casero_id = auth.uid()
    )
  );

-- Nueva política para que caseros actualicen incidencias usando propiedad_id
CREATE POLICY "Caseros pueden actualizar incidencias de sus propiedades"
  ON incidencias FOR UPDATE
  TO authenticated
  USING (
    propiedad_id IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM propiedades p
      WHERE p.id = incidencias.propiedad_id
      AND p.casero_id = auth.uid()
    )
  )
  WITH CHECK (
    propiedad_id IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM propiedades p
      WHERE p.id = incidencias.propiedad_id
      AND p.casero_id = auth.uid()
    )
  );