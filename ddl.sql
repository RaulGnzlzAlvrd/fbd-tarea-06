
--CREAMOS BASE DE DATOS

--Seleccionamos master para creación de base
USE Master;
--Validamos en sys si la base ya existe
PRINT N'Validamos si la base existe';
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'FBD2020_1_5312_TAREA_06')
BEGIN
PRINT N'Base ya existe';
DROP DATABASE FBD2020_1_5312_TAREA_06;
END;
--Creamos la base
CREATE DATABASE FBD2020_1_5312_TAREA_06
ON PRIMARY
(
NAME = 'FBD2020_1_5312_TAREA_06',
FILENAME = '/fbd/fundamentos/FBD2020_1_5312_TAREA_06.mdf',
SIZE = 5MB,
MAXSIZE = UNLIMITED,
FILEGROWTH = 100%
)
LOG ON
(
NAME = 'FBD2020_1_5312_TAREA_06_Log',
FILENAME = '/fbd/fundamentos/FBD2020_1_5312_TAREA_06_Log.ldf',
SIZE = 5MB,
MAXSIZE = 100MB,
FILEGROWTH = 5MB
);
PRINT N'Base de datos creada correctamente';

--CREAMOS TABLAS DE LA BASE DE DATOS
SET DATEFORMAT dmy
USE FBD2020_1_5312_TAREA_06;
--Eliminar tablar si es que existen
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.colaborar') )
	DROP TABLE "dbo"."colaborar"
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.trabajar') )
	DROP TABLE "dbo"."trabajar"
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.proyectos') )
	DROP TABLE "dbo"."proyectos"
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.empleados') )
	DROP TABLE "dbo"."empleados"
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.empresas') )
	DROP TABLE "dbo"."empresas"

-- Creamos las tablas
CREATE TABLE [empleados] (
  [curp] varchar(18) PRIMARY KEY,
  [nombre] varchar(50),
  [paterno] varchar(50),
  [materno] varchar(50),
  [nacimiento] date,
  [genero] char(1),
  [calle] varchar(50),
  [num] varchar(50),
  [ciudad] varchar(50),
  [cp] varchar(5),
  [supervisado_por] varchar(18) NOT NULL,
  [dirigir_empresa] varchar(20) DEFAULT (null),
  [fecha_inicio] date DEFAULT (null)
);

CREATE TABLE [empresas] (
  [rfc] varchar(20) PRIMARY KEY,
  [razon_social] varchar(50),
  [calle] varchar(50),
  [num] varchar(50),
  [ciudad] varchar(50),
  [cp] varchar(5)
);

CREATE TABLE [proyectos] (
  [num_proyecto] integer PRIMARY KEY IDENTITY(1, 1),
  [nombre] varchar(50),
  [fecha_fin] date,
  [fecha_inicio] date,
  [controlado_por] varchar(20) NOT NULL
);

CREATE TABLE [trabajar] (
  [curp] varchar(18),
  [rfc] varchar(20),
  [fecha_ingreso] date,
  [salario_quincenal] real,
  PRIMARY KEY ([curp], [rfc])
);

CREATE TABLE [colaborar] (
  [curp] varchar(18),
  [num_proyecto] integer,
  [fecha_incio] date,
  [fecha_fin] date,
  [num_horas] integer,
  PRIMARY KEY ([curp], [num_proyecto])
);

-- Creamos las llaves foraneas
ALTER TABLE [empleados] ADD FOREIGN KEY ([supervisado_por]) REFERENCES [empleados] ([curp]);

ALTER TABLE [empleados] ADD FOREIGN KEY ([dirigir_empresa]) REFERENCES [empresas] ([rfc]);

ALTER TABLE [trabajar] ADD FOREIGN KEY ([curp]) REFERENCES [empleados] ([curp]);

ALTER TABLE [trabajar] ADD FOREIGN KEY ([rfc]) REFERENCES [empresas] ([rfc]);

ALTER TABLE [proyectos] ADD FOREIGN KEY ([controlado_por]) REFERENCES [empresas] ([rfc]);

ALTER TABLE [colaborar] ADD FOREIGN KEY ([curp]) REFERENCES [empleados] ([curp]);

ALTER TABLE [colaborar] ADD FOREIGN KEY ([num_proyecto]) REFERENCES [proyectos] ([num_proyecto]);
