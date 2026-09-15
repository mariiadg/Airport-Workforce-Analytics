4. Ночная и дневная загрузка
Количество рейсов и пассажиров у каждого агента в ночную и дневную смены. Пассажиры делятся на количество агентов на рейсе, чтобы избежать задвоения. Учитываются только агенты (и стажеры) основного состава (Regular, Agent (и Intern)).
Гипотеза: в ночную смену работают одни агенты, в дневную — другие.
- Подтверждена.

Запрос: 

SELECT 
a.agent_id,
a.agent_name,
COUNT(DISTINCT CASE WHEN s.shift_type = 'Day' THEN sf.shift_flight_id END) AS day_flights, -- Количество рейсов за дневные смены
COUNT(DISTINCT CASE WHEN s.shift_type = 'Night' THEN sf.shift_flight_id END) AS night_flights, -- Количество рейсов за ночные смены
COUNT(DISTINCT sf.shift_flight_id) AS total_flights, -- Итого рейсов за дневные и ночные смены
COUNT(DISTINCT CASE WHEN s.shift_type = 'Day' AND fa.assignment_type = 'Check_in' THEN sf.shift_flight_id END) AS cday_flights, -- Только регистрации за дневные смены
COUNT(DISTINCT CASE WHEN s.shift_type = 'Night' AND fa.assignment_type = 'Check_in' THEN sf.shift_flight_id END) AS cnight_flights, -- Только регистрации за ночные смены
COUNT(DISTINCT CASE WHEN fa.assignment_type = 'Check_in' THEN sf.shift_flight_id END) AS tot_cflights, -- Итого регистрации
COUNT(DISTINCT CASE WHEN s.shift_type = 'Day' AND fa.assignment_type = 'Boarding' THEN sf.shift_flight_id END) AS bday_flights, -- Только посадки за дневные смены
COUNT(DISTINCT CASE WHEN s.shift_type = 'Night' AND fa.assignment_type = 'Boarding' THEN sf.shift_flight_id END) AS bnight_flights, -- Только посадки за ночные смены
COUNT(DISTINCT CASE WHEN fa.assignment_type = 'Boarding' THEN sf.shift_flight_id END) AS tot_bflights,-- Итого посадок
FLOOR(SUM(CASE WHEN s.shift_type = 'Day' AND fa.assignment_type = 'Check_in' THEN sf.pax_total/NULLIF(cac.cia_ag, 0) ELSE 0 END)) AS cday_pax, -- Зарегистрированные в дневные смены пассажиры
FLOOR(SUM(CASE WHEN s.shift_type = 'Night' AND fa.assignment_type = 'Check_in' THEN sf.pax_total/NULLIF(cac.cia_ag, 0) ELSE 0 END)) AS cnight_pax, -- Зарегистрированные в ночные смены пассажиры
FLOOR(SUM(CASE WHEN fa.assignment_type = 'Check_in' THEN sf.pax_total/NULLIF(cac.cia_ag,0) ELSE 0 END)) AS ctotal_pax, -- Всего пассажиров зарегистрировано
FLOOR(SUM(CASE WHEN s.shift_type = 'Day' AND fa.assignment_type = 'Boarding' THEN sf.pax_total/NULLIF(bac.bd_ag, 0) ELSE 0 END)) AS bday_pax, -- Посажено пассажиров в дневные смены
FLOOR(SUM(CASE WHEN s.shift_type = 'Night' AND fa.assignment_type = 'Boarding' THEN sf.pax_total/NULLIF(bac.bd_ag, 0) ELSE 0 END)) AS bnight_pax, -- Посажено пассажиров в ночные смены
FLOOR(SUM(CASE WHEN fa.assignment_type = 'Boarding' THEN sf.pax_total / NULLIF(bac.bd_ag, 0) ELSE 0 END))  AS btotal_pax, -- Всего посаженных пассажиров
COUNT(DISTINCT s.shift_id) AS shift_amount -- Количество отработанных смен
FROM shift_flights sf
LEFT JOIN bdg_ag_count bac ON sf.shift_flight_id = bac.shift_flight_id
LEFT JOIN cia_ag_count cac ON sf.shift_flight_id = cac.shift_flight_id
JOIN shifts s ON sf.shift_id = s.shift_id
JOIN flight_assignments fa ON sf.shift_flight_id = fa.shift_flight_id
JOIN agents a ON fa.agent_id = a.agent_id
WHERE a.agent_role IN ('Agent', 'Intern') AND a.agent_type = 'Regular' -- Выбираем только агентов и стажеров из смены
GROUP BY a.agent_id, a.agent_name
HAVING COUNT(DISTINCT s.shift_id) > 10 -- Выбираем только тех агентов, кто отработал больше 10 смен, чтобы исключить больничные, отпуска
ORDER BY total_flights DESC;
