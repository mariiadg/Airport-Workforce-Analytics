
**1. Общий рейтинг агентов**

Суммарное количество рейсов и пассажиров по каждому агенту с разбивкой на регистрацию и посадку. Учитываются рейсы на сложных DCS (Expert, Medium); агенты, отработавшие минимум 8 смен. Итоговый ранг по общему количеству зарегистрированных и посаженных пассажиров.

*Гипотеза: Нагрузка распределена неравномерно. Существуют агенты, которые обслуживают в разы больше пассажиров, чем другие, при одинаковых должностях и количестве смен.*

```sql
-- Создадим представление, которое фильтрует только агентов, работающих в основном составе смены.
CREATE VIEW regular_agents AS
SELECT a.agent_id, a.agent_name
FROM agents a
JOIN assignment_types at ON a.assignment_type_id = at.assignment_type_id
JOIN agent_roles ar ON a.role_id = ar.role_id
WHERE at.assignment_type = 'Regular' AND ar.role_name = 'Agent';

-- Объединим таблицы назначений на регистрацию и посадку.
WITH all_assignments AS (
    SELECT agent_id, shift_flight_id, 'checkin' AS assign_type
    FROM check_in_assignments
    UNION ALL
    SELECT agent_id, shift_flight_id, 'boarding'
    FROM boarding_assignments
),
-- Считаем количество агентов, работавших на рейсе.
agent_load AS (
    SELECT shift_flight_id, assign_type, COUNT(DISTINCT agent_id) AS agents_on_flight
    FROM all_assignments
    GROUP BY shift_flight_id, assign_type
),
-- Присваиваем агенту ранг.
agent_stats AS (
    SELECT
        ra.agent_id,
        ra.agent_name,
        COUNT(DISTINCT CASE WHEN aa.assign_type = 'checkin' THEN aa.shift_flight_id END) AS checkin_flights,
        COUNT(DISTINCT CASE WHEN aa.assign_type = 'boarding' THEN aa.shift_flight_id END) AS boarding_flights,
        COUNT(DISTINCT aa.shift_flight_id) AS total_flights,
        ROUND(SUM(CASE WHEN aa.assign_type = 'checkin' THEN sf.pax_total / al.agents_on_flight END)) AS checkin_pax,
        FLOOR(SUM(CASE WHEN aa.assign_type = 'boarding' THEN sf.pax_total / al.agents_on_flight END)) AS boarding_pax,
        COUNT(DISTINCT sf.shift_id) AS shift_count,
        COUNT(DISTINCT CASE WHEN dcs.dcs_level IN ('Expert','Medium') THEN dcs.dcs_id END) AS hard_dcs_flights
    FROM regular_agents ra
    JOIN all_assignments aa ON ra.agent_id = aa.agent_id
    JOIN shift_flights sf ON aa.shift_flight_id = sf.shift_flight_id
    JOIN dcs ON sf.dcs_id = dcs.dcs_id
    JOIN agent_load al ON aa.shift_flight_id = al.shift_flight_id AND aa.assign_type = al.assign_type
    GROUP BY ra.agent_id, ra.agent_name
    HAVING shift_count >= 8
)
-- Выделяем ТОП-3 по рангу.
SELECT * FROM (
    SELECT *, DENSE_RANK() OVER (ORDER BY total_flights DESC) AS agent_rank
    FROM agent_stats
) ranked
WHERE agent_rank <= 3;
