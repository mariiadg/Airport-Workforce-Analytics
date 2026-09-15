5. Regular and extra agents.
Сравнение укомплектованности рейсов агентами regular и extra, согласно ПВТР нормативу: 1 агент на 50 пассажиров на рейсе. Учитываются только регистрации (676 рейсов)
Гипотеза: Привлечение extra agent не оправдано. Это лишние операционные расходы.
- Не подтверждена

Запрос №1:

WITH check_in_counts AS ( -- СТЕ, показывающий план и факт количества агентов на регистрации
SELECT 
sf.shift_flight_id,
sf.pax_total,
CEIL(sf.pax_total / 50) AS required_agents,
COUNT(DISTINCT CASE WHEN a.agent_type = 'Regular' THEN a.agent_id END) AS regular_agents,
COUNT(DISTINCT CASE WHEN a.agent_type = 'Extra' THEN a.agent_id END) AS extra_agents
FROM shift_flights sf
JOIN flight_assignments fa ON sf.shift_flight_id = fa.shift_flight_id
JOIN agents a ON fa.agent_id = a.agent_id
WHERE fa.assignment_type = 'Check_in'
GROUP BY sf.shift_flight_id, sf.pax_total
)
SELECT shift_flight_id, pax_total, required_agents, regular_agents, extra_agents,
regular_agents + extra_agents AS total_agents,
CASE
WHEN regular_agents + extra_agents < required_agents THEN 'Нехватка'
WHEN regular_agents >= required_agents AND extra_agents > 0 THEN 'Избыток'
ELSE 'Норма'
END AS check_result
FROM check_in_counts
ORDER BY shift_flight_id;

Запрос №2:

WITH check_in_counts AS ( -- СТЕ, показывающий план и факт количества агентов на регистрации
SELECT 
sf.shift_flight_id,
sf.pax_total,
CEIL(sf.pax_total / 50) AS required_agents,
COUNT(DISTINCT CASE WHEN a.agent_type = 'Regular' THEN a.agent_id END) AS regular_agents,
COUNT(DISTINCT CASE WHEN a.agent_type = 'Extra' THEN a.agent_id END) AS extra_agents
FROM shift_flights sf
JOIN flight_assignments fa ON sf.shift_flight_id = fa.shift_flight_id
JOIN agents a ON fa.agent_id = a.agent_id
WHERE fa.assignment_type = 'Check_in'
GROUP BY sf.shift_flight_id, sf.pax_total
)
SELECT -- % рейсов с нехваткой агентов
CASE
WHEN regular_agents + extra_agents < required_agents THEN 'Нехватка даже с Extra'
WHEN regular_agents < required_agents AND regular_agents + extra_agents >= required_agents THEN 'Extra закрыли нехватку'
WHEN regular_agents >= required_agents AND extra_agents > 0 THEN 'Избыток агентов'
ELSE 'Укомплектован без Extra'
END AS status,
COUNT(*) AS flights_amount,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percent
FROM check_in_counts
GROUP BY status
ORDER BY percent DESC;
