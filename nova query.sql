SELECT * FROM Absenteism_at_work

SELECT * FROM compensation

SELECT * FROM Reasons


-- 1. Taxa de Absenteísmo por Período
SELECT 
    "Month_of_absence" AS month,
    2023 AS year, -- Ano fixo, já que a coluna de ano não existe no arquivo
    COUNT(ID) AS total_ausência,
    COUNT(DISTINCT ID) AS ausência_funionário,
    ROUND(COUNT(ID) * 100.0 / (SELECT COUNT(DISTINCT ID) FROM Absenteism_at_work), 2) AS taxa_ausência
FROM 
    Absenteism_at_work
WHERE 
    "Month_of_absence" BETWEEN 1 AND 12 -- Filtra apenas os meses válidos
GROUP BY 
    "Month_of_absence"
ORDER BY 
    year, month;

--Média de Faltas por Funcionário
SELECT 
    a.ID,
    COUNT(a.ID) AS total_ausência,
    ROUND(AVG(c.comp_hr), 2) AS média_ausencia_funcionário
FROM compensation c
LEFT JOIN Absenteism_at_work a ON a.ID = c.ID
GROUP BY a.ID
ORDER BY total_ausência DESC;

--Custo das Faltas
SELECT 
    a.ID,
    r.Reason,
    COUNT(*) AS contagem_ausência,
    SUM(a.Absenteeism_time_in_hours) AS total_horas,
    ROUND(SUM(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS total_custo
FROM Absenteism_at_work a
JOIN compensation c ON a.ID = c.ID
JOIN Reasons r ON a.Reason_for_absence = r.Number
GROUP BY a.ID, r.Reason
ORDER BY total_custo DESC;

--Distribuição dos Motivos de Falta
SELECT 
    r.Reason,
    COUNT(*) AS contagem_ausência,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Absenteism_at_work), 2) AS porcentagem
FROM Absenteism_at_work a
JOIN Reasons r ON a.Reason_for_absence = r.Number
GROUP BY r.Reason
ORDER BY contagem_ausência DESC;

--Análise Temporal - Tendências por Dia da Semana
SELECT 
    DATENAME(Day, Day_of_the_week) AS dia_semana,
    COUNT(*) AS contagem_ausência,
    ROUND(AVG(Absenteeism_time_in_hours), 2) AS media_duração
FROM Absenteism_at_work
GROUP BY DATENAME(Day, Day_of_the_week)
ORDER BY DATENAME(Day, Day_of_the_week);

--Identificação de Faltas Frequentes (Alerta)
WITH FrequentAbsences AS (
    SELECT 
        ID,
        COUNT(*) AS contagem_ausência,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Absenteism_at_work) AS porcentagem_ausência
    FROM Absenteism_at_work
    WHERE Absenteeism_time_in_hours >= 90
    GROUP BY ID
    --HAVING COUNT(*) > 1
)
SELECT 
    fa.ID,
    fa.contagem_ausência,
    ROUND(fa.porcentagem_ausência, 2) AS porcentagem_total
FROM FrequentAbsences fa
JOIN compensation c ON fa.ID = c.ID
ORDER BY fa.contagem_ausência DESC;

--Análise de Custos por Faixa Salarial
WITH SalaryRanges AS (
    SELECT 
        ID,
        CASE 
            WHEN comp_hr <= 30 THEN '0-30'
            WHEN comp_hr <= 40 THEN '31-40'
            WHEN comp_hr <= 50 THEN '41-50'
            ELSE '50+'
        END AS salary_range
    FROM compensation
)
SELECT 
    sr.salary_range,
    COUNT(DISTINCT c.ID) AS countagem_empregados,
    COUNT(a.ID) AS total_ausências,
    ROUND(AVG(a.Absenteeism_time_in_hours), 2) AS media_duração_ausência,
    ROUND(SUM(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS custo_total
FROM SalaryRanges sr
JOIN compensation c ON sr.ID = c.ID
LEFT JOIN Absenteism_at_work a ON c.ID = a.ID
GROUP BY sr.salary_range
ORDER BY sr.salary_range;


--Análise Mensal de Custos
SELECT 
    Month_of_absence AS Mês,
    Seasons AS Temporada,
    COUNT(*) AS total_ausências,
    ROUND(SUM(Absenteeism_time_in_hours), 2) AS total_hours,
    ROUND(SUM(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS custo_total,
    ROUND(AVG(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS avg_cost_per_absence
FROM 
    Absenteism_at_work a
JOIN 
    compensation c ON a.ID = c.ID
GROUP BY 
    Month_of_absence, Seasons
ORDER BY 
    Temporada, Mês;

--Top 10 Funcionários com Maior Custo de Faltas
SELECT 
    a.ID,
    COUNT(*) AS contagem_ausências,
    ROUND(SUM(Absenteeism_time_in_hours), 2) AS total_horas,
    ROUND(SUM(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS custo_total,
    STUFF((
        SELECT DISTINCT ', ' + r.Reason
        FROM Reasons r
        JOIN Absenteism_at_work a2 ON a2.Reason_for_absence = r.Number
        WHERE a2.ID = a.ID
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS common_reasons
FROM 
    Absenteism_at_work a
JOIN 
    compensation c ON a.ID = c.ID
GROUP BY 
    a.ID
ORDER BY 
    custo_total DESC


=====================================================================
--Novas Queries
--Análise de Padrões de Falta
SELECT 
    DATEPART(WEEKDAY, Day_of_the_week) AS DiaSemana, 
    COUNT(*) AS quantidade_por_dia
FROM 
    Absenteism_at_work
GROUP BY 
    DATEPART(WEEKDAY, Day_of_the_week);


--Índice de Reincidência (mesmo motivo em 30 dias)
SELECT 
    ID, 
    reason_code, 
    COUNT(*) AS Reincidencia
FROM Absenteism_at_work a1
WHERE EXISTS (
    SELECT 1
    FROM Absenteism_at_work a2
    WHERE a1.ID = a2.ID
    AND a1.Reason_for_absence = a2.Reason_for_absence
    AND a2.Day_of_the_week BETWEEN a1.Day_of_the_week 30 DAY AND a1.Day_of_the_week
)
GROUP BY ID, Reason_for_absence;

-- Índice de Reincidência (mesmo motivo em 30 dias)
SELECT 
    a1.ID, 
    a1.Reason_for_absence AS razao_codigo, 
    COUNT(*) AS Reincidencia
FROM 
    Absenteism_at_work a1
WHERE 
    EXISTS (
        SELECT 1
        FROM Absenteism_at_work a2
        WHERE a1.ID = a2.ID
        AND a1.Reason_for_absence = a2.Reason_for_absence
        AND a2.Day_of_the_week BETWEEN DATEADD(DAY, -30, a1.Day_of_the_week) AND a1.Day_of_the_week
    )
GROUP BY 
    a1.ID, 
    a1.Reason_for_absence;


-- Impacto na Produtividade
SELECT 
    (SUM(Absenteeism_time_in_hours) / (8 * COUNT(DISTINCT Day_of_the_week))) * 100 AS qtd_nao_produzida
FROM 
    Absenteism_at_work a;


-- Índice de Sazonalidade
SELECT 
    Month_of_absence AS Mes,
    ((AVG(Absenteeism_time_in_hours) - (
        SELECT AVG(Absenteeism_time_in_hours)
        FROM Absenteism_at_work
        WHERE Month_of_absence = a.Month_of_absence
    )) / (
        SELECT AVG(Absenteeism_time_in_hours)
        FROM Absenteism_at_work
    )) * 100 AS Sazonalidade
FROM 
    Absenteism_at_work a
GROUP BY 
    Month_of_absence;


-- Score de Risco por Funcionário
SELECT 
    a.ID, 
    (SUM(CASE WHEN a.Day_of_the_week BETWEEN DATEADD(DAY, -90, GETDATE()) AND GETDATE() THEN 1 ELSE 0 END) * 0.4) + 
    (SUM(CASE WHEN a.Reason_for_absence = 26 THEN 1 ELSE 0 END) * 0.4) + 
    (SUM(a.Absenteeism_time_in_hours) / AVG(c.comp_hr) * 0.2) AS ScoreRisco
FROM 
    Absenteism_at_work a
JOIN 
    compensation c ON a.ID = c.ID
GROUP BY 
    a.ID;


-- Análise de Clusters de Faltas
SELECT 
    a1.ID, 
    COUNT(*) AS clusters_faltas
FROM 
    Absenteism_at_work a1
WHERE 
    EXISTS (
        SELECT 1
        FROM Absenteism_at_work a2
        WHERE a1.ID = a2.ID
        AND a2.Day_of_the_week BETWEEN a1.Day_of_the_week AND DATEADD(DAY, 2, a1.Day_of_the_week)
    )
GROUP BY 
    a1.ID;


--Índice de Recuperação (Tempo entre faltas)
SELECT 
    ID, 
    AVG(DATEDIFF(
        (SELECT MAX(Day_of_the_week)
         FROM Absenteism_at_work a2
         WHERE a2.ID = a1.ID
         AND a2.Day_of_the_week < a1.Day_of_the_week),
        Day_of_the_week)) AS TempoEntreFaltas
FROM Absenteism_at_work a1
GROUP BY ID;


-- Impacto Financeiro Projetado
SELECT 
    AVG(CustoTotalFaltas) * 12 * 1.1 AS ProjecaoAnual
FROM (
    SELECT 
        ROUND(SUM(CAST(a.Absenteeism_time_in_hours AS DECIMAL(10, 2)) * CAST(c.comp_hr AS DECIMAL(10, 2))), 4) AS CustoTotalFaltas
    FROM 
        Absenteism_at_work a
    JOIN 
        compensation c ON a.ID = c.ID
    GROUP BY 
        a.Month_of_absence
) AS Subquery;


-- Índice de Conformidade
SELECT 
    (SUM(CASE WHEN Reason_for_absence <> 26 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS porcentagem
FROM 
    Absenteism_at_work;




