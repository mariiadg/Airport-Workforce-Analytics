Валидация и исправление данных после сверки с фотографиями

-- 1. При проверке гипотезы о наложениях стоек обнаружено, что регистрация рейса с id = 149 выполнялась на стойках 3 и 34, что невозможно. На фото расписания стойка указана как 33. Данные исправлены

UPDATE flight_assignments
SET check_in_desk_id = 33
WHERE shift_flight_id = 149 AND assignment_type = 'Check_in' AND check_in_desk_id = 3;

-- 2. Проверка всех стоек (номера стоек на одном рейсе должны идти подряд с разницей в 1)
SELECT *
FROM (
SELECT fa.shift_flight_id, fa.agent_id, fa.check_in_desk_id,
LEAD(fa.check_in_desk_id) OVER (
PARTITION BY fa.shift_flight_id 
ORDER BY fa.check_in_desk_id) AS next_desk
FROM flight_assignments fa
WHERE fa.assignment_type = 'Check_in' AND fa.check_in_desk_id IS NOT NULL
) AS desk_check
WHERE next_desk IS NOT NULL AND next_desk - check_in_desk_id != 1;
-- Выявлено 5 аномалий (0,7% от общего числа рейсов). Все — пропуск одной стойки.

-- 3. Детальная информация по аномальным рейсам (номер смены, номер рейса, время вылета, агенты, стойки)
SELECT s.shift_id, fa.shift_flight_id, sf.departure_time, fa.agent_id, a.agent_name, fa.check_in_desk_id 
FROM flight_assignments fa
JOIN shift_flights sf ON fa.shift_flight_id = sf.shift_flight_id
JOIN agents a ON fa.agent_id = a.agent_id
JOIN shifts s ON sf.shift_id = s.shift_id
WHERE fa.shift_flight_id IN (211, 263, 388, 665, 686) AND fa.assignment_type = 'Check_in'
ORDER BY fa.shift_flight_id, fa.check_in_desk_id;

-- 4. Сверка с исходными фотографиями расписаний подтвердила опечатки. Выполняем замены.
UPDATE flight_assignments
SET check_in_desk_id = 9
WHERE shift_flight_id = 211 AND assignment_type = 'Check_in' AND check_in_desk_id = 10;

UPDATE flight_assignments
SET check_in_desk_id = 25
WHERE shift_flight_id = 263 AND assignment_type = 'Check_in' AND check_in_desk_id = 26;

UPDATE flight_assignments
SET check_in_desk_id = 48
WHERE shift_flight_id = 388 AND assignment_type = 'Check_in' AND check_in_desk_id = 49;

UPDATE flight_assignments
SET check_in_desk_id = 41
WHERE shift_flight_id = 665 AND assignment_type = 'Check_in' AND check_in_desk_id = 42;

UPDATE flight_assignments
SET check_in_desk_id = 50
WHERE shift_flight_id = 686 AND assignment_type = 'Check_in' AND check_in_desk_id = 51;

UPDATE flight_assignments
SET check_in_desk_id = 51
WHERE shift_flight_id = 686 AND assignment_type = 'Check_in' AND check_in_desk_id = 52;

-- 5. После исправлений выполнена повторная проверка запросом из п.2. Аномалий не выявлено.
