-- Script de inicialización para el entorno de desarrollo
CREATE TABLE IF NOT EXISTS example_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar algunos datos de ejemplo
INSERT INTO example_table (name, description) VALUES 
('Ejemplo Dev 1', 'Este es un registro de ejemplo para el entorno de desarrollo'),
('Ejemplo Dev 2', 'Otro registro de ejemplo para pruebas');

-- Crear un usuario de solo lectura
CREATE USER readonly WITH PASSWORD 'readonly';
GRANT CONNECT ON DATABASE dev_database TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;
