8. Самые загруженные стойки регистрации
Какие стойки регистрации используются чаще всего и какими агентами.
Гипотеза: одни и те же агенты работают на самых загруженных стойках.
- Не подтверждена. 
  
Запрос №1:

-- Вычисляем количество рейсов, оформленных на каждой стойке регистрации и сортируем по убыванию.
SELECT cid.check_in_desk_id, 
COUNT(DISTINCT fa.shift_flight_id) AS flights_count
FROM flight_assignments fa
JOIN check_in_desks cid ON fa.check_in_desk_id = cid.check_in_desk_id
WHERE fa.assignment_type = 'Check_in'
GROUP BY cid.check_in_desk_id
ORDER BY flights_count DESC;

Запрос №2:
-- Используем CTE (на основе Запроса №1) для фильтрации стоек, количество оформленных рейсов на которых было > 20. Это нужно, чтобы исключить из анализа стойки с низкой загрузкой, где 2-3 обслуживания 1 агента могут дать искаженно высокий процент.
WITH desk_top AS (
SELECT cid.check_in_desk_id,
COUNT(DISTINCT fa.shift_flight_id) AS total_flights
FROM flight_assignments fa
JOIN check_in_desks cid ON fa.check_in_desk_id = cid.check_in_desk_id
WHERE fa.assignment_type = 'Check_in'
GROUP BY cid.check_in_desk_id
HAVING COUNT(DISTINCT fa.shift_flight_id) > 20
)
-- Выводим % рейсов (от общего количества рейсов на стойке), оформленных каждым агентом на стойке.
SELECT cid.check_in_desk_id,
a.agent_name,
COUNT(DISTINCT fa.shift_flight_id) AS agent_flights,
dt.total_flights,
ROUND(COUNT(DISTINCT fa.shift_flight_id) * 100.0 / dt.total_flights, 1) AS pct_of_desk
FROM flight_assignments fa
JOIN check_in_desks cid ON fa.check_in_desk_id = cid.check_in_desk_id
JOIN agents a ON fa.agent_id = a.agent_id
JOIN desk_top dt ON cid.check_in_desk_id = dt.check_in_desk_id
WHERE fa.assignment_type = 'Check_in'
GROUP BY cid.check_in_desk_id, a.agent_name, dt.total_flights
ORDER BY cid.check_in_desk_id, pct_of_desk DESC;
