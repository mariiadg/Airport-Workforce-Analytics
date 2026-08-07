2. Универсальность агентов

Количество уникальных систем регистрации и авиакомпаний, с которыми работал каждый агент. Учитываются только агенты основного состава (Regular), работающих на более 3 различных DCS, среди которых есть системы уровня Medium или Expert.

Гипотеза: Сложные и разнообразные рейсы закреплены за узкой группой агентов, остальные работают на ограниченном наборе систем и направлений.

```sql
-- Используем VIEW regular_agents AS ra из предыдущего запроса и считаем количество уникальных DCS и авиакомпаний для каждого Regular агента.
-- Учитываем только тех, у кого более 3 DCS, среди которых есть Medium или Expert.
-- Используем представление regular_agents, созданное в первой метрике.
SELECT ra.agent_name,
       COUNT(DISTINCT dcs.dcs_id)   AS dcs_count,
       COUNT(DISTINCT ar.airline_id) AS airline_count
FROM regular_agents AS ra
JOIN check_in_assignments cia ON ra.agent_id = cia.agent_id
JOIN shift_flights sf ON cia.shift_flight_id = sf.shift_flight_id
JOIN flights f ON sf.flight_id = f.flight_id
JOIN airlines ar ON f.airline_id = ar.airline_id
JOIN dcs ON sf.dcs_id = dcs.dcs_id
WHERE dcs.dcs_level IN ('Medium', 'Expert')
GROUP BY ra.agent_id, ra.agent_name
HAVING COUNT(DISTINCT dcs.dcs_id) > 3
ORDER BY dcs_count DESC;

