-- Consulta 9: colegio con mejor asistencia promedio en 2019
SELECT 
    C.Nombre AS Colegio,
    CO.Nombre AS Comuna,
    ROUND(AVG(asist_por_alumno.total), 2) AS PromedioAsistencia
FROM (
    SELECT 
        E.IdColegio,
        AC.IdAlumno,
        COUNT(A.Id) AS total
    FROM ASISTENCIA A
    JOIN ALU_CURSO AC    ON A.IdAluCurso = AC.Id
    JOIN CURSO CU        ON AC.IdCurso = CU.Id
    JOIN PROF_CURSO PC   ON CU.Id = PC.IdCurso
    JOIN PROFESOR P      ON PC.IdProfesor = P.Id
    JOIN EMPLEADO E      ON P.IdEmpleado = E.Id
    WHERE CU.Anio = 2019
    GROUP BY E.IdColegio, AC.IdAlumno
) AS asist_por_alumno
JOIN COLEGIO C  ON asist_por_alumno.IdColegio = C.Id
JOIN COMUNA CO  ON C.IdComuna = CO.Id
GROUP BY C.Id, C.Nombre, CO.Nombre
ORDER BY PromedioAsistencia DESC
LIMIT 1;

-- Consulta 10: colegio con mas alumnos por año
SELECT DISTINCT ON (CU.Anio)
    C.Nombre AS Colegio,
    CU.Anio AS Año,
    COUNT(DISTINCT AC.IdAlumno) AS TotalAlumnos
FROM ALU_CURSO AC
JOIN CURSO CU       ON AC.IdCurso = CU.Id
JOIN PROF_CURSO PC  ON CU.Id = PC.IdCurso
JOIN PROFESOR P     ON PC.IdProfesor = P.Id
JOIN EMPLEADO E     ON P.IdEmpleado = E.Id
JOIN COLEGIO C      ON E.IdColegio = C.Id
GROUP BY C.Id, C.Nombre, CU.Anio
ORDER BY CU.Anio ASC, TotalAlumnos DESC;