-- ============================================================
--  Laboratorio 4 - Austral Editores
--  Base de datos de una editorial (4 tablas)
--  ICN292 - Sistemas de Información para la Gestión
-- ============================================================

-- 1) Se crea la base desde cero y se selecciona
DROP DATABASE IF EXISTS austral_editores;
CREATE DATABASE austral_editores;
USE austral_editores;
-- ============================================================
--  TABLAS
-- ============================================================

-- colecciones va primero porque libros la usa como clave foránea
CREATE TABLE colecciones (
    id_coleccion       INT AUTO_INCREMENT,
    titulo             VARCHAR(120) NOT NULL,
    fecha_publicacion  DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- Tabla base del catálogo (pais puede quedar vacío)
CREATE TABLE autores (
    id_autor    INT AUTO_INCREMENT,
    nombre      VARCHAR(80) NOT NULL,
    pais        VARCHAR(60),
    genero      ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Cada libro tiene un autor y pertenece a una colección
CREATE TABLE libros (
    id_libro             INT AUTO_INCREMENT,
    id_autor             INT,
    id_coleccion         INT,
    titulo               VARCHAR(120) NOT NULL,
    paginas              INT,
    ejemplares_vendidos  INT,
    anio                 INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

-- Pagos que la editorial le hace a cada autor
CREATE TABLE pagos (
    id_pago     INT AUTO_INCREMENT,
    id_autor    INT,
    fecha_pago  DATE NOT NULL,
    monto       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

-- ============================================================
--  CARGA OFICIAL
-- ============================================================

INSERT INTO autores (nombre, pais, genero) VALUES
('Elena Pizarro',     'Chile',          'Novela'),    -- 1
('Harold Finch',      'Inglaterra',     'Ensayo'),    -- 2
('Rodrigo Bahamonde', 'Chile',          'Poesía'),    -- 3
('Valentina Correa',  'Argentina',      'Infantil'),  -- 4
('Nora Keller',       'Estados Unidos', 'Novela');    -- 5

-- Kenji no tiene país ni libros, sirve para probar los campos vacíos
INSERT INTO autores (nombre, pais, genero) VALUES ('Kenji Arakawa', NULL, 'Cómic');  -- 6

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
(1, 'Cielo de Enero',      210, 1500, 2024),
(1, 'Marea Baja',          185,  800, 2023),
(1, 'El Norte',            200, 2200, 2024),
(2, 'Estrellas que Caen',  240, 3000, 2022),
(2, 'Máquinas',            215,  450, 2024),
(3, 'Luz Artificial',      300, 1200, 2024),
(3, 'Ruido Blanco',        280,  600, 2023),
(4, 'El Barrio de Lila',   190, 5000, 2024),
(4, 'Antes del Amanecer',  205, 2700, 2024),
(4, 'La Calle 8',          175,  900, 2023),
(5, 'Flor de Hierro',      195, 4100, 2024),
(5, 'Hora Dorada',         220, 1800, 2022);

-- Para revisar que quedó todo cargado
SELECT * FROM autores;
SELECT * FROM libros;

-- ============================================================
--  CONSULTAS
-- ============================================================

-- Consulta 1
-- Autores que no son de Chile (incluye al que no tiene país)
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2
-- Libros que tienen de 190 a 220 páginas, de menor a mayor
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas;

-- Consulta 3
-- Resumen de todo el catálogo en una sola fila
SELECT COUNT(*)                   AS cantidad_libros,
       SUM(ejemplares_vendidos)   AS ejemplares_totales,
       AVG(paginas)               AS promedio_paginas,
       MIN(anio)                  AS primer_anio,
       MAX(ejemplares_vendidos)   AS mayor_venta
FROM   libros;

-- Consulta 4
-- Géneros de los autores sin repetir, de la A a la Z
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- Consulta 5
-- Autores con más de un libro en 2024 y cuántos tienen
SELECT   a.nombre, COUNT(*) AS cantidad_2024
FROM     autores a
JOIN     libros  l ON a.id_autor = l.id_autor
WHERE    l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING   COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6
-- Top 3 de libros de 2024 que pasaron los 2000 ejemplares
SELECT   titulo, ejemplares_vendidos
FROM     libros
WHERE    anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- Consulta 7
-- Se apaga el modo seguro para poder borrar filtrando por título
SET SQL_SAFE_UPDATES = 0;

-- Libro nuevo de Rodrigo Bahamonde (id_autor 3)
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

-- Se revisa que el libro esté antes de borrarlo
SELECT * FROM libros
WHERE titulo = 'Papel Mojado';

DELETE FROM libros
WHERE titulo = 'Papel Mojado';

-- Se revisa de nuevo: ya no debería aparecer
SELECT * FROM libros
WHERE titulo = 'Papel Mojado';

-- Consulta 8
-- Cuántos ejemplares tiene Cielo de Enero antes del cambio
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- Se le suman 100 a lo que ya tenía
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- Cuántos tiene después del cambio
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- Consulta 9
-- Datos de prueba: tres colecciones
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
('Kidd Voodoo', '2000-10-09'),  -- 1
('Playa',       '2004-10-25'),  -- 2
('Animales',    '2024-11-03');  -- 3

SELECT * FROM colecciones;

-- Cada libro va a una colección según cuánto vendió
UPDATE libros SET id_coleccion = 1 WHERE ejemplares_vendidos >= 2500;                -- Kidd Voodoo
UPDATE libros SET id_coleccion = 2 WHERE ejemplares_vendidos BETWEEN 1000 AND 2499;  -- Playa
UPDATE libros SET id_coleccion = 3 WHERE ejemplares_vendidos < 1000;                 -- Animales

-- Cada libro con su colección y la fecha en que salió la colección
SELECT l.titulo AS libro,
       c.titulo AS coleccion,
       c.fecha_publicacion
FROM   libros l
JOIN   colecciones c ON l.id_coleccion = c.id_coleccion
ORDER BY c.id_coleccion, l.ejemplares_vendidos DESC;

-- Consulta 10
-- Datos de prueba: pagos a los autores (Harold, Rodrigo y Valentina reciben dos)
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
(1, '2005-04-04', 300000.00),  -- Elena Pizarro
(2, '2025-06-23', 400000.00),  -- Harold Finch
(2, '2020-12-12',  39000.00),  -- Harold Finch
(3, '2023-10-26', 500000.00),  -- Rodrigo Bahamonde
(3, '2024-07-08', 250000.00),  -- Rodrigo Bahamonde
(4, '2019-04-05', 330000.00),  -- Valentina Correa
(4, '2021-08-15', 245000.00);  -- Valentina Correa

SELECT * FROM pagos;

-- Sentencia 1: cada pago con el nombre de quien lo recibió
SELECT a.nombre, p.fecha_pago, p.monto
FROM   pagos p
JOIN   autores a ON p.id_autor = a.id_autor
ORDER BY a.nombre, p.fecha_pago;

-- Sentencia 2: cuánto se le ha pagado en total a cada autor
SELECT   a.nombre, SUM(p.monto) AS total_recibido
FROM     pagos p
JOIN     autores a ON p.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY total_recibido DESC;
