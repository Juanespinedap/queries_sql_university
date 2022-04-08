-- Scripts Of University

-- Queries to extract relevant information from the university institution

-- what is the highest tuition for the tutor with id = 20
SELECT colegiatura, tutor_id
FROM university.alumnos
WHERE tutor_id = 20
GROUP BY colegiatura, tutor_id
ORDER BY colegiatura DESC
LIMIT 1 OFFSET 1;

-- Select the entire table with the filters of: (1) tutor with id = 20 (2) second value that is most repeated in the tuition column
SELECT *
FROM university.alumnos
WHERE colegiatura = (
	SELECT colegiatura
	FROM university.alumnos
	GROUP BY colegiatura
	ORDER BY colegiatura DESC
	LIMIT 1 OFFSET 1
)
AND tutor_id = 20;

-- Bring the info of the row_id 1,3,5,7
SELECT *
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM university.alumnos
) AS alumnos_with_rows_num
WHERE row_id IN (1,3,5,7);

-- Extract the id of the alumnos, where the id of the tutor is equal to 30
SELECT *
FROM university.alumnos
WHERE alumnos.id IN (
	SELECT id
	FROM university.alumnos
	WHERE tutor_id = 30
);

-- Extract date and time data from alumnos table
SELECT 	EXTRACT(YEAR FROM fecha_incorporacion) AS anio_incorporacion,
		EXTRACT(MONTH FROM fecha_incorporacion) AS mes_incorporacion,
		EXTRACT(DAY FROM fecha_incorporacion) AS dia_incorporacion,
		EXTRACT(HOUR FROM fecha_incorporacion) AS hora_incorporacion,
		EXTRACT(MINUTE FROM fecha_incorporacion) AS minuto_incorporacion,
		EXTRACT(SECOND FROM fecha_incorporacion) AS segundo_incorporacion
FROM university.alumnos;

-- Filter the table of alumnos by the year 2019
SELECT *
FROM (
	SELECT *,
		DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion
	FROM university.alumnos
) AS alumnos_con_anio
WHERE anio_incorporacion = 2019;

-- Check if there are duplicates in the table of alumnos
SELECT *
FROM (
	SELECT id, ROW_NUMBER() OVER(
	PARTITION BY
		nombre,
		apellido,
		email,
		colegiatura,
		fecha_incorporacion,
		carrera_id,
		tutor_id
	ORDER BY id ASC
	) AS row,
	*
	FROM university.alumnos
) AS duplicados
WHERE duplicados.row > 1;

-- Delete duplicates in the table of alumnos
DELETE FROM university.alumnos
WHERE id IN(
	SELECT id
	FROM (
		SELECT id, ROW_NUMBER() OVER(
		PARTITION BY
			nombre,
			apellido,
			email,
			colegiatura,
			fecha_incorporacion,
			carrera_id,
			tutor_id
		ORDER BY id ASC
		) AS row
		FROM university.alumnos
	) AS duplicados
	WHERE duplicados.row > 1
);

-- How many students is assigned to each tutor? Get the top 5
SELECT 	CONCAT(t.nombre,' ', t.apellido) AS tutor,
		COUNT(*) AS alumnos_por_tutor
FROM university.alumnos AS a
	INNER JOIN university.alumnos AS t
	ON a.tutor_id = t.id
GROUP BY tutor
ORDER BY alumnos_por_tutor DESC
LIMIT 5;

-- Place a column so that it has as values a ranking according to the colegiatura column
SELECT 	*,
		DENSE_RANK() OVER(PARTITION BY carrera_id ORDER BY colegiatura DESC) AS colegiatura_rank
FROM university.alumnos
ORDER BY carrera_id, colegiatura_rank

