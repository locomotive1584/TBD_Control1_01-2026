-- Consulta 1:  Lista de profesores con su sueldo, indicando si son o no profesores jefe y los
--              alumnos de su jefatura, si corresponde.

With alumnoCursos AS (
SELECT al.nombre AS nombre, al.apellido as apellido, ac.idcurso as idcurso
FROM alumno al

INNER JOIN alu_curso ac
ON ac.idalumno = al.id)

SELECT em.nombre, pro.especializacion, sue.cantidad, procur.esjefe, acu.nombre, acu.apellido
from empleado em
Inner JOIN sueldo sue
ON sue.id = em.idsueldo
INNER Join profesor pro
ON pro.idempleado = em.id
INNER JOIN prof_curso procur
On procur.idprofesor = pro.id

LEFT join alumnoCursos acu
On acu.idcurso = procur.idcurso
AND procur.esjefe = TRUE

-- Consulta 5: Identificar por curso a los alumnos que no han faltado nunca.

WITH totalClasesPorCurso AS (
    SELECT 
        c.Id AS id_curso,
        COUNT(DISTINCT fh.Id) AS total_clases
    FROM CURSO c
    JOIN PROF_CURSO pc ON pc.IdCurso = c.Id
    JOIN FRANJA_HORARIA fh ON fh.IdProfCurso = pc.Id
    GROUP BY c.Id
),
asistenciasPorAlumnoCurso AS (
    SELECT 
        ac.IdCurso AS id_curso,
        ac.IdAlumno AS id_alumno,
        COUNT(DISTINCT a.IdFranjaHoraria) AS clases_asistidas
    FROM ALU_CURSO ac
    LEFT JOIN ASISTENCIA a ON a.IdAluCurso = ac.Id
    GROUP BY ac.IdCurso, ac.IdAlumno
)
SELECT 
    col.Nombre AS colegio,
    pc.Nombre AS nombre_curso,
    c.Anio AS año,
    al.Nombre AS nombre_alumno,
    al.Apellido AS apellido_alumno
FROM asistenciasPorAlumnoCurso aac
JOIN totalClasesPorCurso tc ON tc.id_curso = aac.id_curso
JOIN CURSO c ON c.Id = aac.id_curso
JOIN PANTILLA_CURSO pc ON pc.Id = c.IdPantillaCurso
JOIN COLEGIO col ON col.Id = c.IdColegio
JOIN ALUMNO al ON al.Id = aac.id_alumno
WHERE aac.clases_asistidas = tc.total_clases
ORDER BY colegio, nombre_curso, año, apellido_alumno, nombre_alumno;


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