-- ============================================
-- BACKUP - DELGADO ABOGADOS
-- ============================================

DROP DATABASE IF EXISTS delgado_abogados;
CREATE DATABASE delgado_abogados;
USE delgado_abogados;

SET FOREIGN_KEY_CHECKS=0;

-- ============================================
-- TABLA: usuarios
-- ============================================

DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL
);

INSERT INTO usuarios VALUES
(1,'Juan Perez','jperez','1234');

-- ============================================
-- TABLA: aseguradoras
-- ============================================

DROP TABLE IF EXISTS aseguradoras;
CREATE TABLE aseguradoras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO aseguradoras VALUES
(1,'ASSA'),
(2,'ANCON'),
(3,'CONANCE'),
(4,'PARTICULAR'),
(5,'INTEROCEANICA');

-- ============================================
-- TABLA: juzgados
-- ============================================

DROP TABLE IF EXISTS juzgados;
CREATE TABLE juzgados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO juzgados VALUES
(1,'Juzgado 1RO Pedregal'),
(2,'Juzgado 2DO Pedregal'),
(3,'Juzgado 3RO Pedregal'),
(4,'Juzgado 4TO Pedregal'),
(5,'Juzgado 5TO Pedregal'),
(6,'Alcaldia de Panama'),
(7,'Chitre');

-- ============================================
-- TABLA: tipos_caso
-- ============================================

DROP TABLE IF EXISTS tipos_caso;
CREATE TABLE tipos_caso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

INSERT INTO tipos_caso VALUES
(1,'Transito'),
(2,'Penal');

-- ============================================
-- TABLA: abogados
-- ============================================

DROP TABLE IF EXISTS abogados;
CREATE TABLE abogados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO abogados VALUES
(1,'Lic. Diane Campbell'),
(2,'Lic. Harold Gray'),
(3,'Lic. William Harris'),
(4,'Lic. Keith Lee'),
(5,'Lic. Samuel Jackson'),
(6,'Lic. Ryan Berry'),
(7,'Lic. Katherine Green'),
(8,'Lic. Tiffany Hawkins');

-- ============================================
-- TABLA: expedientes
-- ============================================

DROP TABLE IF EXISTS expedientes;
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
    FOREIGN KEY (tipo_caso_id) REFERENCES tipos_caso(id),
    FOREIGN KEY (abogado_id) REFERENCES abogados(id),
    FOREIGN KEY (juzgado_id) REFERENCES juzgados(id)
);

INSERT INTO expedientes VALUES
(1,'5435435','Franco Campbell',1,2,2,2,'En curso','2019-01-09','2019-03-15'),
(2,'1001','Anthony Trejo',1,1,1,5,'Pendiente','2019-01-07',NULL),
(3,'1002','Angel Delgado',2,1,2,4,'En curso','2019-01-07',NULL),
(4,'1003','Ricardo de Alba',1,2,3,5,'Pendiente','2019-01-07',NULL),
(5,'1004','Martin Amado Martinez',1,1,4,3,'Cerrado','2017-03-09','2018-01-01'),
(6,'1005','Erick Vega',2,1,2,4,'Cerrado','2018-02-13','2019-01-01'),
(7,'1006','Melissa Diaz',3,2,1,6,'En curso','2018-11-02',NULL),
(8,'1007','Guillermo Ungo',2,1,3,4,'Pendiente','2019-07-12',NULL),
(9,'1008','Gilda de Goldner',1,2,1,5,'Cerrado','2019-01-07','2019-06-01'),
(10,'1009','Yolanda Mora de Valdes',2,1,2,3,'Pendiente','2019-02-09',NULL);

-- ============================================
-- VISTAS
-- ============================================

DROP VIEW IF EXISTS v_expedientes_completos;
CREATE VIEW v_expedientes_completos AS
SELECT
    e.id,
    e.numero_caso,
    e.conductor,
    a.nombre AS aseguradora,
    tc.nombre AS tipo_caso,
    ab.nombre AS abogado,
    j.nombre AS juzgado,
    e.estado,
    e.fecha_inicio,
    e.fecha_fin
FROM expedientes e
JOIN aseguradoras a  ON e.aseguradora_id = a.id
JOIN tipos_caso tc   ON e.tipo_caso_id   = tc.id
JOIN abogados ab     ON e.abogado_id     = ab.id
JOIN juzgados j      ON e.juzgado_id     = j.id;

DROP VIEW IF EXISTS v_resumen_estados;
CREATE VIEW v_resumen_estados AS
SELECT estado, COUNT(*) AS total
FROM expedientes
GROUP BY estado;

DROP VIEW IF EXISTS v_expedientes_por_abogado;
CREATE VIEW v_expedientes_por_abogado AS
SELECT
    ab.nombre AS abogado,
    COUNT(e.id) AS total_expedientes,
    SUM(CASE WHEN e.estado = 'Pendiente' THEN 1 ELSE 0 END) AS pendientes,
    SUM(CASE WHEN e.estado = 'En curso' THEN 1 ELSE 0 END) AS en_curso,
    SUM(CASE WHEN e.estado = 'Cerrado' THEN 1 ELSE 0 END) AS cerrados
FROM abogados ab
LEFT JOIN expedientes e ON e.abogado_id = ab.id
GROUP BY ab.id, ab.nombre;

SET FOREIGN_KEY_CHECKS=1;