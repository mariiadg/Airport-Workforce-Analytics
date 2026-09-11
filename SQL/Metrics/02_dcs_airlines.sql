2. Универсальность агентов
Количество уникальных систем регистрации и авиакомпаний, с которыми работал каждый агент. Отдельно учтены системы регистрации среднего и сложного уровня.
Гипотеза: Сложные и разнообразные рейсы закреплены за узкой группой агентов, остальные работают на ограниченном наборе систем и направлений.
- Подтверждена.

SELECT a.agent_id, a.agent_name, 
COUNT(DISTINCT dcs.dcs_id) AS dcs_count,
COUNT(DISTINCT CASE WHEN dcs.dcs_level IN ('Medium', 'Expert') THEN dcs.dcs_id END) AS medcs_count,
COUNT(DISTINCT al.airline_id) AS airlines_count
FROM agents a 
JOIN flight_assignments fa ON a.agent_id = fa.agent_id
JOIN shift_flights sf ON fa.shift_flight_id = sf.shift_flight_id
JOIN dcs ON sf.dcs_id = dcs.dcs_id
JOIN flights f ON sf.flight_id = f.flight_id
JOIN airlines al ON f.airline_id = al.airline_id
GROUP BY a.agent_id
ORDER BY dcs_count DESC;
