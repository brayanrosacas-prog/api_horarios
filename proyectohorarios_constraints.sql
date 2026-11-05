CREATE DATABASE proyectohorarios;
USE proyectohorarios;

CREATE TABLE carreras (
  clave_carrera   VARCHAR(15) PRIMARY KEY,
  nombre_carrera  VARCHAR(100) UNIQUE NOT NULL,
  poblacion       INT NOT NULL DEFAULT 0,
CONSTRAINT chk_car_poblacion CHECK (poblacion >= 0));

CREATE TABLE edificios (
  no_edi   INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE area (
  clave_area VARCHAR(10) PRIMARY KEY,
  nombre     VARCHAR(100) NOT NULL
);

CREATE TABLE periodo_escolar (
  id_periodo  INT AUTO_INCREMENT PRIMARY KEY,
  periodo     ENUM('ENE-JUN', 'AGO-DIC', 'JUL') NOT NULL,
  anio        INT NOT NULL,
CONSTRAINT uq_per_periodo_anio UNIQUE (periodo, anio),
CONSTRAINT chk_per_anio CHECK (anio BETWEEN 2000 AND 2100));

CREATE TABLE empleados (
  no_trabajador  VARCHAR(10) PRIMARY KEY,
  nombre         VARCHAR(40) NOT NULL,
  ape_pat        VARCHAR(40) NOT NULL,
  ape_mat        VARCHAR(40) NULL,
  genero         ENUM('H', 'M') NOT NULL,
  fecha_na       DATE NOT NULL,
  tipo_personal  ENUM('ADMINISTRATIVO', 'DOCENTE', 'AMBOS') NOT NULL,
  tipo_docente   ENUM('BASE', 'INTERINATO', 'HONORARIOS') NULL,
  estatus        ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  fecha_contratacion DATE NOT NULL,
  fecha_baja     DATE NULL,
CONSTRAINT chk_emp_tipo_docente CHECK (
  (tipo_personal = 'ADMINISTRATIVO' AND tipo_docente IS NULL)
  OR (tipo_personal IN ('DOCENTE', 'AMBOS') AND tipo_docente IS NOT NULL)
),
CONSTRAINT chk_emp_baja CHECK (
  (estatus = 'ACTIVO' AND fecha_baja IS NULL)
  OR (estatus = 'INACTIVO' AND fecha_baja IS NOT NULL)
),
CONSTRAINT chk_emp_fechas CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_contratacion),
CONSTRAINT chk_emp_nacimiento CHECK (fecha_contratacion > fecha_na));

CREATE TABLE materias (
  clave_materia   VARCHAR(10) PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  no_creditos     INT NOT NULL,
  fk_matclave     VARCHAR(10) NULL,
CONSTRAINT chk_mat_creditos CHECK (no_creditos BETWEEN 1 AND 10),
CONSTRAINT chk_mat_requisito CHECK (fk_matclave <> clave_materia),
CONSTRAINT fk_mat_requisito FOREIGN KEY (fk_matclave) REFERENCES materias(clave_materia));

CREATE TABLE alumnos (
  no_control     VARCHAR(10) PRIMARY KEY,
  nombre         VARCHAR(40) NOT NULL,
  s_nombre       VARCHAR(40) NULL,
  ape_pat        VARCHAR(40) NOT NULL,
  ape_mat        VARCHAR(40) NULL,
  fecha          DATE NOT NULL,
  genero         ENUM('H', 'M') NOT NULL,
  nacionalidad   VARCHAR(60) NOT NULL,
  creditos_acumulados INT NOT NULL DEFAULT 0,
  situacion      ENUM('VIGENTE', 'BAJA TEMPORAL', 'BAJA DEFINITIVA', 'INACTIVO', 'EGRESADO') NOT NULL DEFAULT 'VIGENTE',
  fk_alucar      VARCHAR(15) NOT NULL,
CONSTRAINT chk_alu_creditos CHECK (creditos_acumulados >= 0),
CONSTRAINT fk_alu_carrera FOREIGN KEY (fk_alucar) REFERENCES carreras(clave_carrera)
  ON UPDATE CASCADE);

CREATE TABLE reticula (
  clave_reticula  VARCHAR(10) PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  fk_carrera_clave VARCHAR(15) NOT NULL,
CONSTRAINT fk_ret_carrera FOREIGN KEY (fk_carrera_clave) REFERENCES carreras(clave_carrera)
  ON UPDATE CASCADE);

CREATE TABLE salones (
  id_salon   INT AUTO_INCREMENT PRIMARY KEY,
  tipo_salon ENUM('AULA', 'LABORATORIO', 'AUDITORIO') NOT NULL,
  nombre     VARCHAR(100) NOT NULL,
  fk_edisal  INT NOT NULL,
CONSTRAINT uq_sal_edificio_nombre UNIQUE (fk_edisal, nombre),
CONSTRAINT fk_sal_edificio FOREIGN KEY (fk_edisal) REFERENCES edificios(no_edi));

CREATE TABLE modulos (
  clave_modulo INT AUTO_INCREMENT PRIMARY KEY,
  nombre_especialidad VARCHAR(100) NOT NULL,
  fk_retmod           VARCHAR(10) NOT NULL,
CONSTRAINT fk_mod_reticula FOREIGN KEY (fk_retmod) REFERENCES reticula(clave_reticula)
  ON UPDATE CASCADE);

CREATE TABLE materias_reticula (
  id_matret   INT AUTO_INCREMENT PRIMARY KEY,
  fk_matmat   VARCHAR(10) NOT NULL,
  fk_retmat   VARCHAR(10) NOT NULL,
CONSTRAINT uq_matret UNIQUE (fk_matmat, fk_retmat),
CONSTRAINT fk_matret_materia FOREIGN KEY (fk_matmat) REFERENCES materias (clave_materia)
  ON UPDATE CASCADE,
CONSTRAINT fk_matret_reticula FOREIGN KEY (fk_retmat) REFERENCES reticula (clave_reticula)
  ON UPDATE CASCADE);

CREATE TABLE empleados_area (
  fk_empemp VARCHAR(10) NOT NULL,
  fk_areemp VARCHAR(10) NOT NULL,
  rol       ENUM('JEFE', 'SUB JEFE') NULL,
PRIMARY KEY (fk_empemp, fk_areemp),
CONSTRAINT fk_emparea_empleado FOREIGN KEY (fk_empemp) REFERENCES empleados(no_trabajador)
  ON UPDATE CASCADE,
CONSTRAINT fk_emparea_area FOREIGN KEY (fk_areemp) REFERENCES area(clave_area)
  ON UPDATE CASCADE);

CREATE TABLE horario_empleados (
  id_horario_emp INT AUTO_INCREMENT PRIMARY KEY,
  dia_semana     ENUM('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO') NOT NULL,
  hora_entrada   TIME NOT NULL,
  hora_salida    TIME NOT NULL,
  fk_emphor      VARCHAR(10) NOT NULL,
CONSTRAINT chk_he_horas CHECK (hora_salida > hora_entrada),
CONSTRAINT chk_he_rango CHECK (hora_entrada >= '07:00:00' AND hora_salida <= '22:00:00'),
CONSTRAINT fk_he_empleado FOREIGN KEY (fk_emphor) REFERENCES empleados(no_trabajador)
  ON UPDATE CASCADE);

CREATE TABLE usuarios (
  id_usuario   VARCHAR(50) PRIMARY KEY,
  password     VARCHAR(255) NOT NULL,
  correo       VARCHAR(80) UNIQUE NOT NULL,
  tipo         ENUM('DOCENTE', 'ALUMNO', 'ADMINISTRATIVO') NOT NULL,
  fk_empusu    VARCHAR(10) UNIQUE NULL,
  fk_aluusu    VARCHAR(10) UNIQUE NULL,
CONSTRAINT chk_usu_tipo CHECK (
  (tipo = 'ALUMNO' AND fk_aluusu IS NOT NULL AND fk_empusu IS NULL)
  OR (tipo IN ('DOCENTE', 'ADMINISTRATIVO') AND fk_empusu IS NOT NULL AND fk_aluusu IS NULL)
),
CONSTRAINT chk_usu_correo CHECK (correo LIKE '%_@_%._%'),
CONSTRAINT fk_usu_empleado FOREIGN KEY (fk_empusu) REFERENCES empleados(no_trabajador),
CONSTRAINT fk_usu_alumno FOREIGN KEY (fk_aluusu) REFERENCES alumnos(no_control));

CREATE TABLE inscripciones (
  id_inscripcion  VARCHAR(10) PRIMARY KEY,
  semestre_actual INT NOT NULL,
  fk_perins       INT NOT NULL,
  fk_aluins       VARCHAR(10) NOT NULL,
CONSTRAINT uq_ins_alumno_periodo UNIQUE (fk_aluins, fk_perins),
CONSTRAINT chk_ins_semestre CHECK (semestre_actual BETWEEN 0 AND 12),
CONSTRAINT fk_ins_periodo FOREIGN KEY (fk_perins) REFERENCES periodo_escolar(id_periodo),
CONSTRAINT fk_ins_alumno FOREIGN KEY (fk_aluins) REFERENCES alumnos(no_control)
  ON UPDATE CASCADE);

CREATE TABLE clases (
  id_clase    VARCHAR(10) PRIMARY KEY,
  grupo       VARCHAR(50) NOT NULL,
  fk_percla   INT NOT NULL,
  fk_matmat   VARCHAR(10) NOT NULL,
  fk_salcla   INT NOT NULL,
  fk_empcla   VARCHAR(10) NULL,
CONSTRAINT fk_cla_periodo FOREIGN KEY (fk_percla) REFERENCES periodo_escolar(id_periodo),
CONSTRAINT fk_cla_materia FOREIGN KEY (fk_matmat) REFERENCES materias(clave_materia)
  ON UPDATE CASCADE,
CONSTRAINT fk_cla_salon FOREIGN KEY (fk_salcla) REFERENCES salones(id_salon),
CONSTRAINT fk_cla_docente FOREIGN KEY (fk_empcla) REFERENCES empleados(no_trabajador)
  ON UPDATE CASCADE ON DELETE SET NULL);

CREATE TABLE horarios_clases (
  id_horario_clase   INT AUTO_INCREMENT PRIMARY KEY,
  dia_semana ENUM('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES', 'SABADO') NOT NULL,
  hora_inicio       TIME NOT NULL,
  hora_fin          TIME NOT NULL,
  fk_clahor         VARCHAR(10) NOT NULL,
CONSTRAINT chk_hc_horas CHECK (hora_fin > hora_inicio),
CONSTRAINT chk_hc_rango CHECK (hora_inicio >= '07:00:00' AND hora_fin <= '22:00:00'),
CONSTRAINT fk_hc_clase FOREIGN KEY (fk_clahor) REFERENCES clases(id_clase)
  ON UPDATE CASCADE);

CREATE TABLE kardex (
  id_kar     INT AUTO_INCREMENT PRIMARY KEY,
  tipo_cali  ENUM('ORDINARIO','SEGUNDA OPORTUNIDAD','NO ACREDITA','NO CAPTURADO') NOT NULL,
  calificacion INT NULL,
  fk_inskar  VARCHAR(10) NOT NULL,
  fk_clakar  VARCHAR(10) NOT NULL,
CONSTRAINT uq_kar_inscripcion_clase UNIQUE (fk_inskar, fk_clakar),
CONSTRAINT chk_kar_rango CHECK (calificacion BETWEEN 0 AND 100),
CONSTRAINT chk_kar_captura CHECK (
  (tipo_cali = 'NO CAPTURADO' AND calificacion IS NULL)
  OR (tipo_cali <> 'NO CAPTURADO' AND calificacion IS NOT NULL)
),
CONSTRAINT fk_kar_inscripcion FOREIGN KEY (fk_inskar) REFERENCES inscripciones(id_inscripcion)
  ON UPDATE CASCADE,
CONSTRAINT fk_kar_clase FOREIGN KEY (fk_clakar) REFERENCES clases(id_clase)
  ON UPDATE CASCADE);
