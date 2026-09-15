6. Наложения стоек регистрации.
Частота и закономерности двойных назначений рейсов на стойки.

Гипотеза: Конфликты стоек носят системный характер.

with total_flights AS ( -- Считаю количество рейсов, оформленных на каждой стойке
SELECT fa.check_in_desk_id, 
COUNT(DISTINCT fa.shift_flight_id) AS flights_count
FROM flight_assignments fa
WHERE fa.assignment_type = 'check_in'
GROUP BY fa.check_in_desk_id
)
SELECT fa1.check_in_desk_id, COUNT(*) AS conflict_count, tf.flights_count,
ROUND(COUNT(*) * 100.0 / tf.flights_count, 1) AS conflict_percent -- Какой % составляют наложения от всех рейсов на стойке
FROM flight_assignments fa1
JOIN total_flights tf ON tf.check_in_desk_id = fa1.check_in_desk_id
JOIN flight_assignments fa2 ON fa1.check_in_desk_id = fa2.check_in_desk_id
AND fa1.shift_flight_id < fa2.shift_flight_id -- Джоин по стойкам и id рейса, чтобы не дублировать пары стойка-рейс
JOIN shift_flights sf1 ON fa1.shift_flight_id = sf1.shift_flight_id
JOIN shift_flights sf2 ON fa2.shift_flight_id = sf2.shift_flight_id
WHERE fa1.assignment_type = 'Check_in' AND fa2.assignment_type = 'Check_in'
AND sf1.shift_id = sf2.shift_id -- Пересечение происходит во время одной и той же смены
AND sf1.check_in_start < sf2.check_in_close -- Пересечения по времени
AND sf1.check_in_close > sf2.check_in_start
AND fa1.agent_id <> fa2.agent_id -- На стойки назначены разные агенты
GROUP BY fa1.check_in_desk_id
ORDER BY conflict_count DESC;
