1. Общая статистика 
-- Всего рейсов
SELECT COUNT(shift_flight_id) AS total_flights
FROM shift_flights;

-- Всего пассажиров
SELECT SUM(pax_total) AS pax_amount
FROM shift_flights;

-- Всего смен
SELECT COUNT(shift_id) AS total_shifts
FROM shifts;

-- Всего авиакомпаний
SELECT COUNT(airline_id) AS airlines_amount
FROM airlines;

-- Общее рабочее время
SELECT SUM(TIMESTAMPDIFF(HOUR, shift_start, shift_end)) AS total_work_hours
FROM shifts;

-- Состав персонала
SELECT COUNT(agent_id) AS total_staff,
COUNT(CASE WHEN agent_role = 'Agent' THEN agent_id END) AS agents,
COUNT(CASE WHEN agent_role = 'Intern' THEN agent_id END) AS intern_agents,
COUNT(CASE WHEN agent_role = 'Supervisor' THEN agent_id END) AS supervisors,
COUNT(CASE WHEN agent_role = 'Senior agent' THEN agent_id END) AS senior_agents,
COUNT(CASE WHEN agent_type = 'Extra' THEN agent_id END) AS extra_agents,
COUNT(CASE WHEN agent_type = 'Regular' THEN agent_id END) AS regular_agents
FROM agents;

2. Пассажиры

-- Среднее, минимум и максимум пассажиров на рейс
SELECT MAX(sf.pax_total) AS max_pax,
MIN(sf.pax_total) AS min_pax,
FLOOR(AVG(sf.pax_total)) AS avg_pax
FROM shift_flights sf;

-- Максимум пассажиров, дата рейса и направление
SELECT d.destination_name, sf.pax_total AS max_pax,
DATE(sf.check_in_start) AS flight_date
FROM shift_flights sf
JOIN flights f ON sf.flight_id = f.flight_id
JOIN destinations d ON f.destination_id = d.destination_id
ORDER BY sf.pax_total DESC
LIMIT 1;

-- Минимум пассажиров, дата рейса и направление
SELECT d.destination_name, sf.pax_total AS min_pax,
DATE(sf.check_in_start) AS flight_date
FROM shift_flights sf
JOIN flights f ON sf.flight_id = f.flight_id
JOIN destinations d ON f.destination_id = d.destination_id
ORDER BY sf.pax_total ASC
LIMIT 1;

3. Нагрузка на смену

-- Сотрудники (среднее, минимум и максимум за смену)
SELECT FLOOR(AVG(staff_amount)) AS avg_staff_per_shift,
MIN(staff_amount) AS min_staff_per_shift,
MAX(staff_amount) AS max_staff_per_shift
FROM (
SELECT 
sf.shift_id,
COUNT(DISTINCT fa.agent_id) AS staff_amount
FROM shift_flights sf
JOIN flight_assignments fa ON sf.shift_flight_id = fa.shift_flight_id
GROUP BY sf.shift_id
) AS shift_staff;

-- Пассажиры (среднее, минимум и максимум за смену)
SELECT ROUND(AVG(total_pax), 0) AS avg_pax_per_shift,
MIN(total_pax) AS min_pax_per_shift,
MAX(total_pax) AS max_pax_per_shift
FROM (
SELECT 
sf.shift_id,
SUM(sf.pax_total) AS total_pax
FROM shift_flights sf
GROUP BY sf.shift_id
) AS shift_pax;

-- Рейсы (среднее, минимум и максимум за смену)
SELECT ROUND(AVG(flights_amount), 0) AS avg_flights_per_shift,
MIN(flights_amount) AS min_flights_per_shift,
MAX(flights_amount) AS max_flights_per_shift
FROM (
SELECT 
sf.shift_id,
COUNT(sf.shift_flight_id) AS flights_amount
FROM shift_flights sf
GROUP BY sf.shift_id
) AS shift_flights_count;

4. Типы рейсов

-- Международные и внутренние рейсы
SELECT COUNT(CASE WHEN flight_type_name = 'International' THEN sf.shift_flight_id END) AS international_flights,
COUNT(CASE WHEN flight_type_name = 'Domestic' THEN sf.shift_flight_id END) AS domestic_flights
FROM shift_flights sf 
JOIN flight_types ft ON sf.flight_type_id = ft.flight_type_id;

5. ТОПы - 10

-- По направлениям
SELECT d.destination_id, d.destination_name, 
COUNT(sf.shift_flight_id) AS flights_amount
FROM shift_flights sf
JOIN flights f ON sf.flight_id = f.flight_id
JOIN destinations d ON f.destination_id = d.destination_id
GROUP BY d.destination_id, d.destination_name
ORDER BY flights_amount DESC
LIMIT 10;

-- По типам воздушных судов
SELECT aty.aircraft_type_id, aty.model,
COUNT(sf.shift_flight_id) AS flights_amount
FROM shift_flights sf
JOIN aircraft_types aty ON sf.aircraft_type_id = aty.aircraft_type_id
GROUP BY aty.aircraft_type_id, aty.model
ORDER BY flights_amount DESC
LIMIT 10;


