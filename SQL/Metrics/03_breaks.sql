3. Окна между рейсами
Средняя длительность перерывов у каждого агента. Перерыв — это время между закрытием регистрации предыдущего рейса и началом регистрации следующего в рамках одной смены. Учитываются только агенты основного состава (regular_agents).
Гипотеза: перерывы распределены неравномерно между агентами.
- Подтверждена частично.

Запрос:

-- Считаю перерывы между рейсами у регулярных агентов внутри смены
WITH breaks AS (
SELECT ra.agent_id, ra.agent_name, s.shift_id, sf.check_in_start, sf.check_in_close,
LAG(sf.check_in_close) OVER (PARTITION BY ra.agent_id, s.shift_id ORDER BY sf.check_in_close ASC) AS previous_check_in_close    -- Время окончания регистрации предыдущего рейса
FROM regular_agents ra 
JOIN flight_assignments fa ON ra.agent_id = fa.agent_id 
JOIN shift_flights sf ON fa.shift_flight_id = sf.shift_flight_id 
JOIN shifts s ON sf.shift_id = s.shift_id 
WHERE fa.assignment_type = 'Check_in'
) 
-- Средний перерыв между рейсами в минутах
SELECT agent_id, agent_name, 
ROUND(AVG(TIMESTAMPDIFF(MINUTE, previous_check_in_close, check_in_start)), 0) AS avg_break 
FROM breaks 
WHERE previous_check_in_close IS NOT NULL AND check_in_start > previous_check_in_close
GROUP BY agent_id, agent_name
HAVING COUNT(DISTINCT shift_id) > 10
ORDER BY avg_break;
