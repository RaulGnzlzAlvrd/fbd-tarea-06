USE FBD2020_1_5312_TAREA_06;

-- a. Encontrar el nombre y la ciudad de todos los empleados que trabajan en PEMEX.
-- YA JALA

--insert into empleados (curp, nombre, paterno, materno, nacimiento, genero, calle, num, ciudad, cp, supervisado_por, dirigir_empresa, fecha_inicio) values ('HAYCTIVIABFRBCWIXP', 'Quintina', 'Galloway', 'Coull', '19/01/1990', 'F', 'Sauthoff', '300', 'Garland', '26979', null, null, null);
--insert into trabajar (curp, rfc, fecha_ingreso, salario_quincenal) values ('HAYCTIVIABFRBCWIXP', 'PEMEXPEMEXPEM', '09/07/1968', '2405.63');

SELECT nombre,
	   paterno,
	   materno,
	   empleados.ciudad,
	   razon_social
FROM empleados
INNER JOIN trabajar ON empleados.curp = trabajar.curp
INNER JOIN empresas ON trabajar.rfc = empresas.rfc
WHERE empresas.razon_social = 'PEMEX';
-- b. Encontrar todos los empleados que no viven en la misma ciudad de la empresa en que trabajan.
-- Jala
SELECT nombre,
	   paterno,
	   materno,
	   empleados.ciudad
FROM trabajar
INNER JOIN empleados ON empleados.curp = trabajar.curp
INNER JOIN empresas ON trabajar.rfc = empresas.rfc
WHERE empleados.ciudad != empresas.ciudad;

-- c. Calcular el salario mensual de todas las directoras.
-- Jala
SELECT nombre,
	   paterno,
	   materno,
	   salario_quincenal * 2 AS SalarioMensual
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
INNER JOIN empleados ON empresas.rfc = empleados.dirigir_empresa
WHERE empleados.genero = 'F';

-- d. Obtener la información de los directores (en general) y empresas que comenzaron a dirigir 
--    durante el segundo y cuarto trimestre de 2018.
-- Ya jala -- SE agregó al script de poblado info encesaria praa mostrar, cuando se poble, checar de nuevo
SELECT empleados.*,
	   empresas.*
FROM empresas 
INNER JOIN empleados ON empleados.dirigir_empresa = empresas.rfc
WHERE (DATEPART(QUARTER, fecha_inicio) = 2 OR  DATEPART(QUARTER, fecha_inicio) = 4) 
		AND DATEPART(YEAR, fecha_inicio) IN (2018);
-- e. Encontrar a todos los empleados que viven en la misma ciudad y en la misma calle que su supervisor.
-- JALA
SELECT e.calle AS calleEmpleado,
	   s.calle AS calleSupervisor,
	   *
FROM empleados e
INNER JOIN empleados s ON s.supervisado_por = e.curp
WHERE s.calle = e.calle;
-- f. Obtener una lista de cada compañía y el salario promedio que paga. La información se debe
--    mostrar por compañía, año, y género.
-- Terminado
SELECT empresas.razon_social AS compania, 
	   empleados.genero, YEAR(trabajar.fecha_ingreso) AS año,
	   AVG(salario_quincenal) AS SalarioPromedio
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
INNER JOIN empleados ON trabajar.curp = empleados.curp
GROUP BY empresas.razon_social, YEAR(trabajar.fecha_ingreso), empleados.genero;

-- g. Empleados que colaboran en proyectos que controlan empresas para las que no trabajan.
-- PENDUENTE
--SELECT empleados.curp, 
--	   empleados.nombre, 
--	   empleados.paterno, 
--	   empleados.materno, 
--	   proyectos.num_proyecto
--FROM colaborar
--INNER JOIN empleados ON empleados.curp = colaborar.curp
--INNER JOIN proyectos ON proyectos.num_proyecto = colaborar.num_proyecto
-- WHERE (empleados.curp, proyectos.rfc) NOT IN (SELECT curp,rfc FROM trabajar); 


-- h. Encontrar el máximo, mínimo y total de salarios pagados por cada compañía.
-- Ya jala
-- Es total count o sum? 
SELECT empresas.razon_social,
	   MAX(salario_quincenal) AS Maximo,
	   MIN(salario_quincenal) AS Minimo,
	   COUNT(salario_quincenal) AS Total
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
GROUP BY empresas.razon_social;

-- i. Encontrar información de los empleados y número de horas que dedican a los proyectos.
--    Interesan aquellos empleados que colaboran en al menos dos proyectos y en donde el
--    número de horas que dediquen a algún proyecto sea mayor a 20.
-- Ya jala
SELECT no_proyectos,
       horas,
       empleados.*
FROM empleados 
-- Hacemos Join para obtener info de esos empleados
INNER JOIN 
	(SELECT curp,
			COUNT(num_proyecto) AS no_proyectos,
			SUM(num_horas) AS horas
	 FROM colaborar 
	 WHERE num_horas > 20
	 GROUP BY curp
	 HAVING COUNT(num_proyecto) >= 2) sub 
ON sub.curp = empleados.curp;

-- j. Encontrar la cantidad de empleados en cada compañía, por año, trimestre y género.
-- Ya jala
SELECT 
	rfc,
	COUNT(trabajar.curp) AS no_empleados_por_compania,
	DATEPART(Y ,trabajar.fecha_ingreso) AS año,
	DATEPART(QUARTER ,trabajar.fecha_ingreso) AS trimestre,
	genero
FROM trabajar
INNER JOIN empleados ON empleados.curp = trabajar.curp 
GROUP BY rfc,DATEPART(QUARTER ,trabajar.fecha_ingreso), DATEPART(Y ,trabajar.fecha_ingreso), genero;


-- k. Encontrar el nombre del empleado que gana más dinero en cada compañía.
-- Ya jala
SELECT empresas.razon_social,
	   nombre,
	   MAX(salario_quincenal) AS MejorPagado
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
INNER JOIN empleados ON empleados.curp = trabajar.curp
GROUP BY empresas.razon_social,nombre;

-- l. Obtener una lista de los empleados que ganan más del salario promedio que pagan las
-- compañías.
-- Ya jala
SELECT nombre,
	   paterno,
	   Salario,
	   PromedioSalario
-- Tabla con los salarios de todos los empleados
FROM
	(SELECT nombre,
			paterno,
		   salario_quincenal AS Salario,
		   empresas.rfc AS rfc
	FROM empresas
	INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
	INNER JOIN empleados ON empleados.curp = trabajar.curp) AS a 
-- Join con la tabla con los promedios de salarios por compania
INNER JOIN (
	SELECT empresas.rfc as rfc,
		   AVG(salario_quincenal) AS PromedioSalario
	FROM empresas
	INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
	GROUP BY empresas.rfc) AS b
ON a.rfc = b.rfc
WHERE Salario > PromedioSalario;

-- m. Encontrar la compañía que tiene menos empleados y listar toda la información de los mismos.
-- Ya jala
-- Hay varias empresas con un empleado.
SELECT min_empleados,
	empleados.*
FROM (SELECT rfc, COUNT(curp) AS no_empleados
	FROM trabajar
	GROUP BY rfc) e 
	INNER JOIN 
	(SELECT MIN(n.no_empleados) AS min_empleados
	FROM (SELECT rfc, COUNT(curp) AS no_empleados
		FROM trabajar
		GROUP BY rfc) AS n) m 
	ON e.no_empleados = m.min_empleados
	INNER JOIN trabajar ON trabajar.rfc = e.rfc
	INNER JOIN empleados ON empleados.curp = trabajar.curp;


-- n. Información de los proyectos en los que colaboran los empleados que son directores.
-- Ya jala
SELECT proyectos.*
FROM empleados
-- Join para saber qué empleados son directores
INNER JOIN empresas ON empleados.dirigir_empresa = empresas.rfc
-- Join para saber los proyectos que colabora un director
INNER JOIN proyectos ON proyectos.controlado_por = empresas.rfc ;

-- o. Encontrar la compañía que tiene empleados en cada una de las ciudades que hayas definido.
-- Jala, falta poblar para que no sea vacia
SELECT a.rfc AS rfc_compania, 
	   COUNT(a.ciudad) AS num_ciudades_definidas
FROM 
	(SELECT  DISTINCT t.rfc, e.ciudad
	FROM empleados e 
	INNER JOIN trabajar t ON t.curp = e.curp) a
	INNER JOIN
		((SELECT DISTINCT ciudad
		FROM empleados)
		UNION
		(SELECT DISTINCT ciudad
		FROM empresas)) b 
	ON a.ciudad = b.ciudad
	GROUP BY a.rfc
	HAVING COUNT(a.ciudad) = (SELECT COUNT(f.ciudad)
							  FROM ((SELECT DISTINCT ciudad
									 FROM empleados)
									 UNION
									 (SELECT DISTINCT ciudad
									 FROM empresas)) f);
-- p. Empleados que dejaron de colaborar en proyectos, antes de la fecha de finalización de los mismos.
-- Ya jala 
SELECT empleados.*
FROM empleados 
INNER JOIN colaborar ON empleados.curp = colaborar.curp
INNER JOIN proyectos ON proyectos.num_proyecto = colaborar.num_proyecto
WHERE colaborar.fecha_fin < proyectos.fecha_fin;

-- q. Información de los empleados que no colaboran en ningún proyecto.
-- Ya jala
SELECT empleados.*
FROM 
	(SELECT curp
	FROM empleados
	EXCEPT 
	SELECT curp
	FROM colaborar) c INNER JOIN empleados  ON c.curp = empleados.curp;
-- r. Encontrar la información de las compañías que tienen al menos dos empleados en la misma ciudad en que tienen sus instalaciones.
--  Terminada
SELECT empresas.rfc, 
	   razon_social,
	   ciudad,
	   no_empleados
FROM (SELECT empresas.rfc, COUNT(empleados.curp) AS no_empleados
	  FROM empleados 
	  INNER JOIN trabajar ON empleados.curp = trabajar.curp
	  INNER JOIN empresas ON empresas.rfc = trabajar.rfc
	  WHERE empleados.ciudad = empresas.ciudad
	  GROUP BY empresas.rfc) sub 
	  INNER JOIN empresas ON empresas.rfc = sub.rfc
WHERE no_empleados >= 2;
-- s. Proyecto que más empleados requiere (o requirió) y el número de horas que éstos le dedicaron.
-- Ya jala
SELECT m.num_proyecto, 
       SUM(num_horas) AS horas_rqueridas
FROM colaborar 
	INNER JOIN
	(SELECT num_proyecto
	FROM (SELECT num_proyecto, COUNT(curp) AS no_empleados
		  FROM colaborar
		  GROUP BY num_proyecto) n
		  INNER JOIN
	      (SELECT MAX(n.no_empleados) AS maximo
		   FROM (SELECT num_proyecto, COUNT(curp) AS no_empleados
				 FROM colaborar
				 GROUP BY num_proyecto) n) m
				 ON m.maximo = n.no_empleados) m 
	ON m.num_proyecto = colaborar.num_proyecto
	GROUP BY m.num_proyecto;

-- t. Empleados que comenzaron a colaborar en proyectos en la misma fecha de su cumpleaños.
-- Ya jala, Modificado poblacion para que jale, probar de nuevo

SELECT empleados.* 
FROM empleados
INNER JOIN colaborar ON empleados.curp = colaborar.curp 
WHERE colaborar.fecha_inicio = empleados.nacimiento;

-- u. Obtener una lista del número de empleados que supervisa cada supervisor.
-- NO hay datos de supervisor para probar

-- v. Obtener una lista de los directores de más de 50 años.
-- YA JALA

SELECT empleados.*
FROM empleados
INNER JOIN empresas ON empleados.dirigir_empresa = empresas.rfc
WHERE (CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),nacimiento ,112))/10000 > 50;

-- w. Obtener una lista de los empleados cuyo apellido paterno comience con las letras A, D, G, J, L, P o R.
-- YA JALA
SELECT *
FROM empleados
WHERE SUBSTRING(paterno,1,1) IN ('A','D','G','J','L','P','R');

-- x. Número de empleados que colaboran en los proyectos que controla cada empresa para aquellos proyectos que hayan iniciado en diciembre.
SELECT COUNT(curp) AS no_empleados
FROM proyectos 
INNER JOIN colaborar ON proyectos.num_proyecto = colaborar.num_proyecto
WHERE DATEPART(M ,proyectos.fecha_inicio) = 12;

-- y. Crea una vista con la información de los empleados y compañías en que trabajan, de aquellos 
--    empleados que lo hagan en al menos tres compañías diferentes.
CREATE VIEW compa_diferentes(curp, nombre, paterno, materno, fecha, calle,
		num, ciudad, cp,supervisado,dirige,fecha_inicio, rfc_empresa, razon_social_empresa, calle_empresa, num_empresa, 
		ciudad_empresa,cp_empresa,b) AS 
(SELECT em2.*, emp.*
FROM (SELECT e.curp
	FROM empleados e
	INNER JOIN
		(SELECT curp, COUNT(rfc) AS num_companias
		FROM trabajar
		GROUP BY curp
		HAVING COUNT(rfc) >= 3) n ON e.curp = n.curp) em1
		INNER JOIN empleados em2 ON em1.curp = em2.curp
		INNER JOIN trabajar tr ON tr.curp = em2.curp
		INNER JOIN empresas emp ON emp.rfc = tr.rfc);