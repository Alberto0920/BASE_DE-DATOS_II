-- ============================================
-- PARCIAL 2 - SISTEMA DE EXPEDIENTES LEGALES
-- DELGADO & DELGADO FIRMA DE ABOGADOS
-- ============================================

CREATE DATABASE IF NOT EXISTS delgado_abogados;
USE delgado_abogados;

-- ============================================
-- TABLAS BASE (1FN, 2FN, 3FN)
-- ============================================

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL
);

CREATE TABLE aseguradoras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE juzgados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE tipos_caso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE abogados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE expedientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_caso VARCHAR(50) NOT NULL,
    conductor VARCHAR(100),
    aseguradora_id INT,
    tipo_caso_id INT,
    abogado_id INT,
    juzgado_id INT,
    estado VARCHAR(20) DEFAULT 'Pendiente',
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (aseguradora_id) REFERENCES aseguradoras(id),
    FOREIGN KEY (tipo_caso_id)   REFERENCES tipos_caso(id),
    FOREIGN KEY (abogado_id)     REFERENCES abogados(id),
    FOREIGN KEY (juzgado_id)     REFERENCES juzgados(id)
);

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO usuarios (nombre, username, password) VALUES
('Juan Perez', 'jperez', '1234');

INSERT INTO aseguradoras (nombre) VALUES
('ASSA'), ('ANCON'), ('CONANCE'), ('PARTICULAR'), ('INTEROCEANICA');

INSERT INTO juzgados (nombre) VALUES
('Juzgado 1RO Pedregal'), ('Juzgado 2DO Pedregal'),
('Juzgado 3RO Pedregal'), ('Juzgado 4TO Pedregal'),
('Juzgado 5TO Pedregal'), ('Alcaldia de Panama'), ('Chitre');

INSERT INTO tipos_caso (nombre) VALUES
('Transito'), ('Penal');

INSERT INTO abogados (nombre) VALUES
('Lic. Diane Campbell'), ('Lic. Harold Gray'), ('Lic. William Harris'),
('Lic. Keith Lee'), ('Lic. Samuel Jackson'), ('Lic. Ryan Berry'),
('Lic. Katherine Green'), ('Lic. Tiffany Hawkins');

INSERT INTO expedientes (numero_caso, conductor, aseguradora_id, tipo_caso_id, abogado_id, juzgado_id, estado, fecha_inicio, fecha_fin) VALUES
('5435435', 'Franco Campbell',      1, 2, 2, 2, 'En curso',  '2019-01-09', '2019-03-15'),
('1001',    'Anthony Trejo',        1, 1, 1, 5, 'Pendiente', '2019-01-07', NULL),
('1002',    'Angel Delgado',        2, 1, 2, 4, 'En curso',  '2019-01-07', NULL),
('1003',    'Ricardo de Alba',      1, 2, 3, 5, 'Pendiente', '2019-01-07', NULL),
('1004',    'Martin Amado Martinez',1, 1, 4, 3, 'Cerrado',   '2017-03-09', '2018-01-01'),
('1005',    'Erick Vega',           2, 1, 2, 4, 'Cerrado',   '2018-02-13', '2019-01-01'),
('1006',    'Melissa Diaz',         3, 2, 1, 6, 'En curso',  '2018-11-02', NULL),
('1007',    'Guillermo Ungo',       2, 1, 3, 4, 'Pendiente', '2019-07-12', NULL),
('1008',    'Gilda de Goldner',     1, 2, 1, 5, 'Cerrado',   '2019-01-07', '2019-06-01'),
('1009',    'Yolanda Mora de Valdes',2,1, 2, 3, 'Pendiente', '2019-02-09', NULL);

-- ============================================
-- VISTAS SQL
-- ============================================

-- Vista 1: Expedientes completos con todos los datos
CREATE VIEW v_expedientes_completos AS
SELECT
    e.id,
    e.numero_caso,
    e.conductor,
    a.nombre  AS aseguradora,
    tc.nombre AS tipo_caso,
    ab.nombre AS abogado,
    j.nombre  AS juzgado,
    e.estado,
    e.fecha_inicio,
    e.fecha_fin
FROM expedientes e
JOIN aseguradoras a  ON e.aseguradora_id = a.id
JOIN tipos_caso   tc ON e.tipo_caso_id   = tc.id
JOIN abogados     ab ON e.abogado_id     = ab.id
JOIN juzgados     j  ON e.juzgado_id     = j.id;

-- Vista 2: Resumen de expedientes por estado (para el dashboard)
CREATE VIEW v_resumen_estados AS
SELECT
    estado,
    COUNT(*) AS total
FROM expedientes
GROUP BY estado;

-- Vista 3: Expedientes por abogado
CREATE VIEW v_expedientes_por_abogado AS
SELECT
    ab.nombre AS abogado,
    COUNT(e.id) AS total_expedientes,
    SUM(CASE WHEN e.estado = 'Pendiente' THEN 1 ELSE 0 END) AS pendientes,
    SUM(CASE WHEN e.estado = 'En curso'  THEN 1 ELSE 0 END) AS en_curso,
    SUM(CASE WHEN e.estado = 'Cerrado'   THEN 1 ELSE 0 END) AS cerrados
FROM abogados ab
LEFT JOIN expedientes e ON e.abogado_id = ab.id
GROUP BY ab.id, ab.nombre;
