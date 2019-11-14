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
	   salario_quincenal * 2
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
INNER JOIN empleados ON empresas.rfc = empleados.dirigir_empresa
WHERE empleados.genero = 'F';

-- d. Obtener la información de los directores (en general) y empresas que comenzaron a dirigir 
--    durante el segundo y cuarto trimestre de 2018.
-- Sin probar
SELECT nombre,
	   paterno,
	   materno,
	   razon_social
FROM empresas
INNER JOIN empleados ON empleados.dirigir_empresa = empresas.rfc
WHERE (fecha_inicio < '06-30-2018' and fecha_inicio > '04-01-2018') or (fecha_inicio > '10-01-2018' and fecha_inicio < '12-31-2018') 

-- e. Encontrar a todos los empleados que viven en la misma ciudad y en la misma calle que su supervisor.
-- PENDIENTE

-- f. Obtener una lista de cada compañía y el salario promedio que paga. La información se debe
--    mostrar por compañía, año, y género.
-- Falta lo de mostrar por compañia, etc
SELECT empresas.razon_social,
	   AVG(salario_quincenal) AS Salario
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
GROUP BY empresas.razon_social;

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
-- j. Encontrar la cantidad de empleados en cada compañía, por año, trimestre y género.
-- k. Encontrar el nombre del empleado que gana más dinero en cada compañía.
SELECT empresas.razon_social,
	   nombre,
	   MAX(salario_quincenal) AS MejorPagado
FROM empresas
INNER JOIN trabajar ON trabajar.rfc = empresas.rfc
INNER JOIN empleados ON empleados.curp = trabajar.curp
GROUP BY empresas.razon_social,nombre;

-- l. Obtener una lista de los empleados que ganan más del salario promedio que pagan las
-- compañías.

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
-- Hay varias empresas con un empleado.
SELECT min_num_empleados,
	a.*
FROM (SELECT rfc, COUNT(curp) AS num_empleados
	FROM trabajar
	GROUP BY rfc) e 
	INNER JOIN 
	(SELECT MIN(n.num_empleados) AS min_num_empleados
	FROM (SELECT rfc, COUNT(curp) AS num_empleados
		FROM trabajar
		GROUP BY rfc) AS n) m 
	ON e.num_empleados = m.min_num_empleados
	INNER JOIN trabajar t ON t.rfc = e.rfc
	INNER JOIN empleados a ON a.curp = t.curp;


-- n. Información de los proyectos en los que colaboran los empleados que son directores.
-- o. Encontrar la compañía que tiene empleados en cada una de las ciudades que hayas  definido.
-- p. Empleados que dejaron de colaborar en proyectos, antes de la fecha de finalización de los mismos.
-- q. Información de los empleados que no colaboran en ningún proyecto.
-- r. Encontrar la información de las compañías que tienen al menos dos empleados en la misma ciudad en que tienen sus instalaciones.
-- s. Proyecto que más empleados requiere (o requirió) y el número de horas que éstos le dedicaron.
-- t. Empleados que comenzaron a colaborar en proyectos en la misma fecha de su cumpleaños.
-- u. Obtener una lista del número de empleados que supervisa cada supervisor.
-- v. Obtener una lista de los directores de más de 50 años.
-- w. Obtener una lista de los empleados cuyo apellido paterno comience con las letras A, D, G, J, L, P o R.
-- x. Número de empleados que colaboran en los proyectos que controla cada empresa para aquellos proyectos que hayan iniciado en diciembre.
-- y. Crea una vista con la información de los empleados y compañías en que trabajan, de aquellos 
--    empleados que lo hagan en al menos tres compañías diferentes.