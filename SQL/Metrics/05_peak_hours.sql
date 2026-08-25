5. Пиковые часы.
Самые загруженные часы по пассажиропотоку в день и в ночь.
Считаем среднее количество пассажиров за 4 часовые периоды по всем сменам.

WITH hourly AS ( -- СТЕ, которое сгруппирует кол-во пассажиров по времени начала регистраций
SELECT HOUR(check_in_start) AS start_hour,
SUM(pax_total) AS pax_amount
FROM shift_flights
GROUP BY HOUR(check_in_start)
)
SELECT 
CONCAT(h.start_hour, ':00-', (h.start_hour + 3) % 24, ':59') AS period, -- Создаем 4 часовые периоды, не выходящиеза предел 24 часов.
ROUND((h.pax_amount + h1.pax_amount + h2.pax_amount + h3.pax_amount) / 14, 0) AS avg_pax_per_shift
FROM hourly h
LEFT JOIN hourly h1 ON h1.start_hour = (h.start_hour + 1) % 24
LEFT JOIN hourly h2 ON h2.start_hour = (h.start_hour + 2) % 24
LEFT JOIN hourly h3 ON h3.start_hour = (h.start_hour + 3) % 24
ORDER BY avg_pax_per_shift DESC;

