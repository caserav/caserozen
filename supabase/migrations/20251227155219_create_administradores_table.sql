/*
  # Crear tabla de administradores

  1. Nueva Tabla
    - `administradores`
      - `id` (uuid, primary key) - Referencia a auth.users
      - `email` (text, unique) - Email del administrador
      - `nombre_completo` (text, opcional) - Nombre del administrador
      - `created_at` (timestamp) - Fecha de creación

  2. Seguridad
    - Enable RLS en tabla administradores
    - Los administradores pueden ver su propia información
    - Solo administradores pueden leer la tabla de administradores

  3. Función auxiliar
    - `is_admin()` - Verifica si el usuario actual es administrador
*/

-- Crear tabla de administradores
CREATE TABLE IF NOT EXISTS administradores (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  nombre_completo text,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE administradores ENABLE ROW LEVEL SECURITY;

-- Política: Los administradores pueden ver su propia información
CREATE POLICY "Administradores pueden ver su info"
  ON administradores
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Función auxiliar para verificar si el usuario es administrador
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM administradores
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Actualizar políticas de incidencias para que administradores vean todo
DROP POLICY IF EXISTS "Caseros ven incidencias de sus inquilinos" ON incidencias;

CREATE POLICY "Caseros y administradores ven incidencias"
  ON incidencias
  FOR SELECT
  TO authenticated
  USING (
    is_admin() OR
    email_inquilino IN (
      SELECT inquilino_email 
      FROM propiedades 
      WHERE casero_id = auth.uid()
    ) OR
    user_id = auth.uid()
  );
