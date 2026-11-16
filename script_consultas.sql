-- =========================================================================
-- TAREA 5: SISTEMA DE CONSULTAS DML Y VISTAS - RED SOCIAL ESTUDIANTIL
-- Motor SGBD: PostgreSQL (OneCompiler)
-- =========================================================================

-- 1. CREACIÓN DE TABLAS (DDL)
CREATE TABLE estudiantes (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    area_estudio VARCHAR(100) NOT NULL,
    semestre INT NOT NULL CHECK (semestre >= 1 AND semestre <= 10)
);

CREATE TABLE intereses (
    id_interes SERIAL PRIMARY KEY,
    nombre_interes VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE estudiante_interes (
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    id_interes INT REFERENCES intereses(id_interes) ON DELETE CASCADE,
    PRIMARY KEY (id_estudiante, id_interes)
);

CREATE TABLE habilidades (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE estudiante_habilidad (
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    id_habilidad INT REFERENCES habilidades(id_habilidad) ON DELETE CASCADE,
    nivel VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad)
);

CREATE TABLE publicaciones (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE grupos (
    id_grupo SERIAL PRIMARY KEY,
    nombre_grupo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE miembro_grupo (
    id_grupo INT REFERENCES grupos(id_grupo) ON DELETE CASCADE,
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    fecha_union DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_grupo, id_estudiante)
);

CREATE TABLE eventos (
    id_evento SERIAL PRIMARY KEY,
    id_organizador INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio TIMESTAMP NOT NULL
);

-- 2. INSERCIÓN DE DATOS DE PRUEBA
INSERT INTO estudiantes (nombre, apellido, correo, area_estudio, semestre) VALUES
('Mariana', 'Rivera', 'mariana.rivera@pascualbravo.edu.co', 'Tecnología en Desarrollo de Software', 3),
('Carlos', 'Gómez', 'carlos.gomez@pascualbravo.edu.co', 'Ingeniería de Software', 6),
('Laura', 'Martínez', 'laura.martinez@pascualbravo.edu.co', 'Tecnología en Desarrollo de Software', 5),
('Andrés', 'López', 'andres.lopez@pascualbravo.edu.co', 'Ingeniería Mecatrónica', 2),
('Sofía', 'Ramírez', 'sofia.ramirez@pascualbravo.edu.co', 'Ingeniería de Software', 8);

INSERT INTO intereses (nombre_interes) VALUES
('Programación Competitiva'), ('Desarrollo Web'), ('Inteligencia Artificial'), ('Videojuegos'), ('Ciberseguridad');

INSERT INTO estudiante_interes VALUES
(1, 1), (1, 2), (2, 1), (2, 3), (3, 2), (3, 5), (4, 4), (5, 3), (5, 1);

INSERT INTO habilidades (nombre_habilidad) VALUES
('C++'), ('PostgreSQL y Bases de Datos'), ('Java'), ('Python'), ('React');

INSERT INTO estudiante_habilidad VALUES
(1, 1, 'Intermedio'), (1, 2, 'Intermedio'),
(2, 1, 'Avanzado'), (2, 3, 'Avanzado'),
(3, 2, 'Avanzado'), (3, 5, 'Intermedio'),
(5, 4, 'Avanzado'), (5, 2, 'Avanzado');

INSERT INTO publicaciones (id_estudiante, tipo, contenido) VALUES
(1, 'Pregunta', '¿Alguien tiene apuntes de normalización y vistas en PostgreSQL?'),
(2, 'Recurso', 'Les comparto esta guía de optimización de consultas SQL.'),
(2, 'Noticia', 'Se abren inscripciones para la maratón interna de programación.'),
(3, 'Meme', 'Cuando olvidas el WHERE en un DELETE FROM en producción...'),
(5, 'Recurso', 'Repositorio con ejemplos de hilos y concurrencia en Java.');

INSERT INTO grupos (nombre_grupo, categoria) VALUES
('Semillero Programación Competitiva', 'Club'),
('Grupo de Estudio Bases de Datos I', 'Estudio'),
('Equipo Hackatón Pascual 2026', 'Hackaton');

INSERT INTO miembro_grupo (id_grupo, id_estudiante) VALUES
(1, 1), (1, 2), (1, 5),
(2, 1), (2, 3),
(3, 2), (3, 3), (3, 5);

INSERT INTO eventos (id_organizador, titulo, descripcion, fecha_hora_inicio) VALUES
(2, 'Taller Intensivo de SQL y Vistas', 'Repaso práctico para el parcial final de Bases de Datos.', '2026-11-25 14:00:00'),
(5, 'Preparación Maratón de Programación', 'Resolución de problemas en C++ y estructuras de datos.', '2026-12-02 16:00:00');


-- =========================================================================
-- PARTE A: LAS 5 CONSULTAS DML SIGNIFICATIVAS
-- =========================================================================

-- Consulta 1: Estudiantes, área de estudio e intereses
SELECT 
    e.id_estudiante,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.area_estudio AS area_principal,
    e.semestre,
    STRING_AGG(i.nombre_interes, ', ') AS lista_intereses
FROM estudiantes e
LEFT JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
LEFT JOIN intereses i ON ei.id_interes = i.id_interes
GROUP BY e.id_estudiante, e.nombre, e.apellido, e.area_estudio, e.semestre;

-- Consulta 2: Conteo de publicaciones por estudiante
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    COUNT(p.id_publicacion) AS total_publicaciones,
    MAX(p.fecha_creacion) AS ultima_publicacion
FROM estudiantes e
LEFT JOIN publicaciones p ON e.id_estudiante = p.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido;

-- Consulta 3: Búsqueda de mentores potenciales (Semestre >= 4)
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS mentor,
    e.semestre,
    e.area_estudio,
    h.nombre_habilidad AS disciplina_mentoria,
    eh.nivel AS nivel_dominio
FROM estudiantes e
JOIN estudiante_habilidad eh ON e.id_estudiante = eh.id_estudiante
JOIN habilidades h ON eh.id_habilidad = h.id_habilidad
WHERE e.semestre >= 4;

-- Consulta 4: Popularidad de grupos de estudio
SELECT 
    g.id_grupo,
    g.nombre_grupo AS grupo,
    g.categoria,
    COUNT(mg.id_estudiante) AS total_miembros
FROM grupos g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria;

-- Consulta 5: Próximos eventos programados
SELECT 
    ev.id_evento,
    ev.titulo AS nombre_evento,
    ev.descripcion,
    ev.fecha_hora_inicio,
    e.nombre || ' ' || e.apellido AS organizador
FROM eventos ev
JOIN estudiantes e ON ev.id_organizador = e.id_estudiante
WHERE ev.fecha_hora_inicio >= CURRENT_TIMESTAMP;


-- =========================================================================
-- PARTE B: LAS 3 VISTAS ANALÍTICAS
-- =========================================================================

-- Vista 1: Perfiles e intereses consolidados
CREATE OR REPLACE VIEW vw_resumen_perfiles_intereses AS
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante_info,
    e.area_estudio,
    e.semestre,
    COALESCE(STRING_AGG(i.nombre_interes, ', '), 'Sin intereses registrados') AS intereses_registrados
FROM estudiantes e
LEFT JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
LEFT JOIN intereses i ON ei.id_interes = i.id_interes
GROUP BY e.id_estudiante, e.nombre, e.apellido, e.area_estudio, e.semestre;

SELECT * FROM vw_resumen_perfiles_intereses;

-- Vista 2: Métricas de participación estudiantil
CREATE OR REPLACE VIEW vw_actividad_estudiantes AS
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    COUNT(DISTINCT p.id_publicacion) AS publicaciones_realizadas,
    COUNT(DISTINCT mg.id_grupo) AS grupos_inscritos,
    COUNT(DISTINCT ev.id_evento) AS eventos_organizados
FROM estudiantes e
LEFT JOIN publicaciones p ON e.id_estudiante = p.id_estudiante
LEFT JOIN miembro_grupo mg ON e.id_estudiante = mg.id_estudiante
LEFT JOIN eventos ev ON e.id_estudiante = ev.id_organizador
GROUP BY e.id_estudiante, e.nombre, e.apellido;

SELECT * FROM vw_actividad_estudiantes;

-- Vista 3: Grupos populares
CREATE OR REPLACE VIEW vw_grupos_populares AS
SELECT 
    g.id_grupo,
    g.nombre_grupo,
    g.categoria,
    COUNT(mg.id_estudiante) AS total_integrantes,
    MAX(mg.fecha_union) AS ultima_incorporacion
FROM grupos g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria;

SELECT * FROM vw_grupos_populares;-- =========================================================================
-- TAREA 5: SISTEMA DE CONSULTAS DML Y VISTAS - RED SOCIAL ESTUDIANTIL
-- Motor SGBD: PostgreSQL (OneCompiler)
-- =========================================================================

-- 1. CREACIÓN DE TABLAS (DDL)
CREATE TABLE estudiantes (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    area_estudio VARCHAR(100) NOT NULL,
    semestre INT NOT NULL CHECK (semestre >= 1 AND semestre <= 10)
);

CREATE TABLE intereses (
    id_interes SERIAL PRIMARY KEY,
    nombre_interes VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE estudiante_interes (
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    id_interes INT REFERENCES intereses(id_interes) ON DELETE CASCADE,
    PRIMARY KEY (id_estudiante, id_interes)
);

CREATE TABLE habilidades (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE estudiante_habilidad (
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    id_habilidad INT REFERENCES habilidades(id_habilidad) ON DELETE CASCADE,
    nivel VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad)
);

CREATE TABLE publicaciones (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE grupos (
    id_grupo SERIAL PRIMARY KEY,
    nombre_grupo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE miembro_grupo (
    id_grupo INT REFERENCES grupos(id_grupo) ON DELETE CASCADE,
    id_estudiante INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    fecha_union DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_grupo, id_estudiante)
);

CREATE TABLE eventos (
    id_evento SERIAL PRIMARY KEY,
    id_organizador INT REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio TIMESTAMP NOT NULL
);

-- 2. INSERCIÓN DE DATOS DE PRUEBA
INSERT INTO estudiantes (nombre, apellido, correo, area_estudio, semestre) VALUES
('Mariana', 'Rivera', 'mariana.rivera@pascualbravo.edu.co', 'Tecnología en Desarrollo de Software', 3),
('Carlos', 'Gómez', 'carlos.gomez@pascualbravo.edu.co', 'Ingeniería de Software', 6),
('Laura', 'Martínez', 'laura.martinez@pascualbravo.edu.co', 'Tecnología en Desarrollo de Software', 5),
('Andrés', 'López', 'andres.lopez@pascualbravo.edu.co', 'Ingeniería Mecatrónica', 2),
('Sofía', 'Ramírez', 'sofia.ramirez@pascualbravo.edu.co', 'Ingeniería de Software', 8);

INSERT INTO intereses (nombre_interes) VALUES
('Programación Competitiva'), ('Desarrollo Web'), ('Inteligencia Artificial'), ('Videojuegos'), ('Ciberseguridad');

INSERT INTO estudiante_interes VALUES
(1, 1), (1, 2), (2, 1), (2, 3), (3, 2), (3, 5), (4, 4), (5, 3), (5, 1);

INSERT INTO habilidades (nombre_habilidad) VALUES
('C++'), ('PostgreSQL y Bases de Datos'), ('Java'), ('Python'), ('React');

INSERT INTO estudiante_habilidad VALUES
(1, 1, 'Intermedio'), (1, 2, 'Intermedio'),
(2, 1, 'Avanzado'), (2, 3, 'Avanzado'),
(3, 2, 'Avanzado'), (3, 5, 'Intermedio'),
(5, 4, 'Avanzado'), (5, 2, 'Avanzado');

INSERT INTO publicaciones (id_estudiante, tipo, contenido) VALUES
(1, 'Pregunta', '¿Alguien tiene apuntes de normalización y vistas en PostgreSQL?'),
(2, 'Recurso', 'Les comparto esta guía de optimización de consultas SQL.'),
(2, 'Noticia', 'Se abren inscripciones para la maratón interna de programación.'),
(3, 'Meme', 'Cuando olvidas el WHERE en un DELETE FROM en producción...'),
(5, 'Recurso', 'Repositorio con ejemplos de hilos y concurrencia en Java.');

INSERT INTO grupos (nombre_grupo, categoria) VALUES
('Semillero Programación Competitiva', 'Club'),
('Grupo de Estudio Bases de Datos I', 'Estudio'),
('Equipo Hackatón Pascual 2026', 'Hackaton');

INSERT INTO miembro_grupo (id_grupo, id_estudiante) VALUES
(1, 1), (1, 2), (1, 5),
(2, 1), (2, 3),
(3, 2), (3, 3), (3, 5);

INSERT INTO eventos (id_organizador, titulo, descripcion, fecha_hora_inicio) VALUES
(2, 'Taller Intensivo de SQL y Vistas', 'Repaso práctico para el parcial final de Bases de Datos.', '2026-11-25 14:00:00'),
(5, 'Preparación Maratón de Programación', 'Resolución de problemas en C++ y estructuras de datos.', '2026-12-02 16:00:00');


-- =========================================================================
-- PARTE A: LAS 5 CONSULTAS DML SIGNIFICATIVAS
-- =========================================================================

-- Consulta 1: Estudiantes, área de estudio e intereses
SELECT 
    e.id_estudiante,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.area_estudio AS area_principal,
    e.semestre,
    STRING_AGG(i.nombre_interes, ', ') AS lista_intereses
FROM estudiantes e
LEFT JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
LEFT JOIN intereses i ON ei.id_interes = i.id_interes
GROUP BY e.id_estudiante, e.nombre, e.apellido, e.area_estudio, e.semestre;

-- Consulta 2: Conteo de publicaciones por estudiante
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    COUNT(p.id_publicacion) AS total_publicaciones,
    MAX(p.fecha_creacion) AS ultima_publicacion
FROM estudiantes e
LEFT JOIN publicaciones p ON e.id_estudiante = p.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido;

-- Consulta 3: Búsqueda de mentores potenciales (Semestre >= 4)
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS mentor,
    e.semestre,
    e.area_estudio,
    h.nombre_habilidad AS disciplina_mentoria,
    eh.nivel AS nivel_dominio
FROM estudiantes e
JOIN estudiante_habilidad eh ON e.id_estudiante = eh.id_estudiante
JOIN habilidades h ON eh.id_habilidad = h.id_habilidad
WHERE e.semestre >= 4;

-- Consulta 4: Popularidad de grupos de estudio
SELECT 
    g.id_grupo,
    g.nombre_grupo AS grupo,
    g.categoria,
    COUNT(mg.id_estudiante) AS total_miembros
FROM grupos g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria;

-- Consulta 5: Próximos eventos programados
SELECT 
    ev.id_evento,
    ev.titulo AS nombre_evento,
    ev.descripcion,
    ev.fecha_hora_inicio,
    e.nombre || ' ' || e.apellido AS organizador
FROM eventos ev
JOIN estudiantes e ON ev.id_organizador = e.id_estudiante
WHERE ev.fecha_hora_inicio >= CURRENT_TIMESTAMP;


-- =========================================================================
-- PARTE B: LAS 3 VISTAS ANALÍTICAS
-- =========================================================================

-- Vista 1: Perfiles e intereses consolidados
CREATE OR REPLACE VIEW vw_resumen_perfiles_intereses AS
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante_info,
    e.area_estudio,
    e.semestre,
    COALESCE(STRING_AGG(i.nombre_interes, ', '), 'Sin intereses registrados') AS intereses_registrados
FROM estudiantes e
LEFT JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
LEFT JOIN intereses i ON ei.id_interes = i.id_interes
GROUP BY e.id_estudiante, e.nombre, e.apellido, e.area_estudio, e.semestre;

SELECT * FROM vw_resumen_perfiles_intereses;

-- Vista 2: Métricas de participación estudiantil
CREATE OR REPLACE VIEW vw_actividad_estudiantes AS
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    COUNT(DISTINCT p.id_publicacion) AS publicaciones_realizadas,
    COUNT(DISTINCT mg.id_grupo) AS grupos_inscritos,
    COUNT(DISTINCT ev.id_evento) AS eventos_organizados
FROM estudiantes e
LEFT JOIN publicaciones p ON e.id_estudiante = p.id_estudiante
LEFT JOIN miembro_grupo mg ON e.id_estudiante = mg.id_estudiante
LEFT JOIN eventos ev ON e.id_estudiante = ev.id_organizador
GROUP BY e.id_estudiante, e.nombre, e.apellido;

SELECT * FROM vw_actividad_estudiantes;

-- Vista 3: Grupos populares
CREATE OR REPLACE VIEW vw_grupos_populares AS
SELECT 
    g.id_grupo,
    g.nombre_grupo,
    g.categoria,
    COUNT(mg.id_estudiante) AS total_integrantes,
    MAX(mg.fecha_union) AS ultima_incorporacion
FROM grupos g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria;

SELECT * FROM vw_grupos_populares;