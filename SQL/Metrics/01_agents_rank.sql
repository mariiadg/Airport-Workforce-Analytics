1. Общий рейтинг агентов

Суммарное количество рейсов и пассажиров по каждому агенту с разбивкой на регистрацию и посадку. Итоговый ранг по балльной системе.

Обязательное условие - минимум 11 отработанных смен (исключить агентов кто был в отпуске, на учебе или на больничном).
Только агенты, работающие в основном составе смены (исключить стажеров, которые работают не самостоятельно, старшего агента и начальника смены, агентов, вышедших на помощь из других смен).

Уровни систем регистрации:
1 балл за Basic DCS
2 балла за Medium DCS
3 балла за Expert DCS

Каждые 500 зарегестрированных пассажиров - 1 балл (500 выбрано как статистически значимая разница при AVG пассажиров на рейсе в 130 человек, т.е. расхождение в ~4 рейса).
Каждая 1000 посаженных пасажиров - 1 балл (посадка занимает в разы меньше времени, и технически легче, чем регистрация, поэтому 1000 человек).

Каждая авиакомпания - 1 балл (каждая авиакомпания имеет совй набор правил и ограничений (рассадка пассажиров, повышение классов обслуживания, габариты ручной клади и т.д.), часть авиакомпаний требуют сдачи зачета дла получения допуска к работе со "своими" пассажирами).

Каждые 10 рейсов - 1 балл (статистически значимый разрыв между агентами - 10 рейсов).

1 международный рейс - 0.5 балла (не все международные рейсы сложнее в плане систем регистрации и правил авиакомпании, но они требуют проверку сроков действия документов, оформление депортированных пассажиров, координацию с пограничной службой при посадке).

Рейс на широкофюзеляжном ВС - 0.3 балла (регистрация на рейсы, выполняющиеся на широкофюзеляжных ВС начинаются за 4 часа до вылета, требуют два комплекта сопроводительнах документов, посадка производится 2 агентами за то же самое время, что посадка среднего рейса, со средним количеством пассажиров)

Гипотеза: Нагрузка распределена неравномерно. Существуют агенты, которые обслуживают в разы больше пассажиров, чем другие, при одинаковых должностях и количестве смен.

WITH agent_score AS -- CTE с полями, по которым будет присваиваться ранг
(
SELECT a.agent_id, a.agent_name,
COUNT(DISTINCT dcs.dcs_id) AS dcs_amount,
COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Basic' THEN dcs.dcs_id END) AS basic_dcs, -- "Базовые" системы регистрации
COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Medium' THEN dcs.dcs_id END) AS medium_dcs, -- "Средние" системы регистрации
COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Expert' THEN dcs.dcs_id END) AS expert_dcs, -- "Сложные" системы регистрации
COUNT(DISTINCT al.airline_id) AS airlines_amount, -- Кол-во авиакомпаний
COUNT(DISTINCT CASE WHEN ft.flight_type_name = 'International' THEN d.destination_id END) AS int_flights, -- Кол-во международных рейсов
COUNT(DISTINCT CASE WHEN act.body = 'Wide-body' THEN sf.shift_flight_id END) AS wb_flights, -- Кол-во широкофюзеляжных рейсов
COUNT(DISTINCT sf.shift_flight_id) AS total_flights, -- Всего рейсов
FLOOR(SUM(sf.pax_total/NULLIF(cac.cia_ag, 0))) AS ctotal_pax, -- Всего зарегистрированных пассажиров
FLOOR(SUM(sf.pax_total/NULLIF(bac.bd_ag,0))) AS btotal_pax, -- Всего посаженых пассажиров
COUNT(DISTINCT s.shift_id) AS shift_amount, -- Кол-во смен
( -- Балльная система по условиям
(COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Basic' THEN dcs.dcs_id END) * 1) + 
(COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Medium' THEN dcs.dcs_id END) * 2) +  
(COUNT(DISTINCT CASE WHEN dcs.dcs_level = 'Expert' THEN dcs.dcs_id END) * 3) +
(COUNT(DISTINCT al.airline_id) * 1) +
(FLOOR(COUNT(DISTINCT sf.shift_flight_id) / 10) * 1) +
(COUNT(DISTINCT CASE WHEN ft.flight_type_name = 'International' THEN sf.shift_flight_id END) * 0.5) +
(COUNT(DISTINCT CASE WHEN act.body = 'wide-body' THEN sf.shift_flight_id END) * 0.3)+
(FLOOR(SUM(sf.pax_total / NULLIF(cac.cia_ag, 0)) / 500) * 1) +
(FLOOR(SUM(sf.pax_total / NULLIF(bac.bd_ag, 0)) / 1000) * 1)
) AS total_score 
FROM shift_flights sf
JOIN dcs ON sf.dcs_id = dcs.dcs_id
JOIN flight_assignments fa ON sf.shift_flight_id = fa.shift_flight_id
JOIN agents a ON fa.agent_id = a.agent_id
JOIN regular_agents ra ON a.agent_id = ra.agent_id
JOIN flights f ON sf.flight_id = f.flight_id
JOIN airlines al ON f.airline_id = al.airline_id
JOIN flight_types ft ON sf.flight_type_id = ft.flight_type_id
JOIN aircraft_types act ON sf.aircraft_type_id = act.aircraft_type_id
LEFT JOIN bdg_ag_count bac ON sf.shift_flight_id = bac.shift_flight_id
LEFT JOIN cia_ag_count cac ON sf.shift_flight_id = cac.shift_flight_id
JOIN destinations d ON f.destination_id = d.destination_id
JOIN shifts s ON sf.shift_id = s.shift_id
GROUP BY a.agent_id
HAVING COUNT(DISTINCT s.shift_id) > 10 -- Отсеиваем тех, кто отработал больше 10 смен
)
SELECT agent_id, agent_name,
basic_dcs, medium_dcs, expert_dcs,
airlines_amount, total_flights, int_flights, wb_flights,
ctotal_pax, btotal_pax,
shift_amount, total_score,
DENSE_RANK () OVER (ORDER BY total_score DESC) AS score_rank
FROM agent_score
ORDER BY score_rank;