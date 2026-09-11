1. Создание БД в MySQL Worckbench

CREATE DATABASE sopp;
USE sopp;

2. Создание 8 справочников

-- Агенты
CREATE TABLE agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(10) NOT NULL,
    agent_role VARCHAR(20),
    agent_type VARCHAR(10)
);

-- Смены
CREATE TABLE shifts (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_type VARCHAR(10) NOT NULL,
    shift_start DATETIME,
    shift_end DATETIME
);

-- Системы регистрации
CREATE TABLE dcs (
    dcs_id INT AUTO_INCREMENT PRIMARY KEY,
    dcs_name VARCHAR(10),
    dcs_level VARCHAR(10)
);

-- Типы воздушных судов
CREATE TABLE aircraft_types (
    aircraft_type_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(20),
    model VARCHAR(10),
    body VARCHAR(20)
);

-- Типы рейсов
CREATE TABLE flight_types (
    flight_type_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_type_name VARCHAR(20)
);

-- Стойки регистрации
CREATE TABLE check_in_desks (
    check_in_desk_id INT AUTO_INCREMENT PRIMARY KEY,
    check_in_desk_number INT NOT NULL,
    terminal VARCHAR(1)
);

-- Направления
CREATE TABLE destinations (
    destination_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_name VARCHAR(50)
);

-- Авиакомпании
CREATE TABLE airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_name VARCHAR(20),
    airline_code VARCHAR(5)
);

3. Создание 2 операционных таблиц

-- Рейсы и направления
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT NOT NULL,
    flight_number INT NOT NULL,
    destination_id INT NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id), -- Связь с авикомпанией
    FOREIGN KEY (destination_id) REFERENCES destinations(destination_id) -- Связь с направлением
);

-- Рейсы в смену. Первоначальная денормализованная таблица, созданная в Excel и анонимизированная с помощью Python.
CREATE TABLE shift_flights (
    shift_flight_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    flight_id INT NOT NULL,
    flight_type_id INT NOT NULL,
    aircraft_type_id INT NOT NULL,
    dcs_id INT NOT NULL,
    departure_time DATETIME,
    check_in_start DATETIME,
    check_in_close DATETIME,
    boarding_start DATETIME,
    pax_total INT,
    shift_handover VARCHAR(5),
    check_in_agent_1 INT,
    check_in_agent_2 INT,
    check_in_agent_3 INT,
    check_in_agent_4 INT,
    boarding_agent_1 INT,
    boarding_agent_2 INT,
    check_in_desk_1 INT,
    check_in_desk_2 INT,
    check_in_desk_3 INT,
    check_in_desk_4 INT,
    FOREIGN KEY (shift_id) REFERENCES shifts(shift_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (flight_type_id) REFERENCES flight_types(flight_type_id),
    FOREIGN KEY (aircraft_type_id) REFERENCES aircraft_types(aircraft_type_id),
    FOREIGN KEY (dcs_id) REFERENCES dcs(dcs_id)
);

-- Внешние ключи к shift_flights
ALTER TABLE shift_flights
ADD CONSTRAINT fk_agent_1 FOREIGN KEY (check_in_agent_1) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_agent_2 FOREIGN KEY (check_in_agent_2) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_agent_3 FOREIGN KEY (check_in_agent_3) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_agent_4 FOREIGN KEY (check_in_agent_4) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_boarding_1 FOREIGN KEY (boarding_agent_1) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_boarding_2 FOREIGN KEY (boarding_agent_2) REFERENCES agents(agent_id),
ADD CONSTRAINT fk_desk_1 FOREIGN KEY (check_in_desk_1) REFERENCES check_in_desks(check_in_desk_id),
ADD CONSTRAINT fk_desk_2 FOREIGN KEY (check_in_desk_2) REFERENCES check_in_desks(check_in_desk_id),
ADD CONSTRAINT fk_desk_3 FOREIGN KEY (check_in_desk_3) REFERENCES check_in_desks(check_in_desk_id),
ADD CONSTRAINT fk_desk_4 FOREIGN KEY (check_in_desk_4) REFERENCES check_in_desks(check_in_desk_id);

4. Создание таблицы, для нормализованного хранения назначений агентов

CREATE TABLE flight_assignments (
assignment_id INT AUTO_INCREMENT PRIMARY KEY,
shift_flight_id INT NOT NULL,
agent_id INT NOT NULL,
assignment_type ENUM('Check_in', 'Boarding') NOT NULL,
check_in_desk_id INT NULL,
FOREIGN KEY (shift_flight_id) REFERENCES shift_flights(shift_flight_id),
FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
FOREIGN KEY (desk_id) REFERENCES check_in_desks(check_in_desk_id)
);

-- Перенос значений из shift_flights в flight_assignments
INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, check_in_agent_1, 'Check_in', check_in_desk_1
FROM shift_flights
WHERE check_in_agent_1 IS NOT NULL;

INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, check_in_agent_2, 'Check_in', check_in_desk_2
FROM shift_flights
WHERE check_in_agent_2 IS NOT NULL;

INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, check_in_agent_3, 'Check_in', check_in_desk_3
FROM shift_flights
WHERE check_in_agent_3 IS NOT NULL;

INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, check_in_agent_4, 'Check_in', check_in_desk_4
FROM shift_flights
WHERE check_in_agent_4 IS NOT NULL;

INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, boarding_agent_1, 'Boarding', NULL
FROM shift_flights
WHERE boarding_agent_1 IS NOT NULL;

INSERT INTO flight_assignments (shift_flight_id, agent_id, assignment_type, desk_id)
SELECT shift_flight_id, boarding_agent_2, 'Boarding', NULL
FROM shift_flights
WHERE boarding_agent_2 IS NOT NULL;

-- Удаление лишних столбцов и внешних ключей из shift_flights
ALTER TABLE shift_flights
DROP FOREIGN KEY fk_agent_1,
DROP FOREIGN KEY fk_agent_2,
DROP FOREIGN KEY fk_agent_3,
DROP FOREIGN KEY fk_agent_4,
DROP FOREIGN KEY fk_boarding_1,
DROP FOREIGN KEY fk_boarding_2,
DROP FOREIGN KEY fk_desk_1,
DROP FOREIGN KEY fk_desk_2,
DROP FOREIGN KEY fk_desk_3,
DROP FOREIGN KEY fk_desk_4;

ALTER TABLE shift_flights
DROP COLUMN check_in_agent_1,
DROP COLUMN check_in_agent_2,
DROP COLUMN check_in_agent_3,
DROP COLUMN check_in_agent_4,
DROP COLUMN boarding_agent_1,
DROP COLUMN boarding_agent_2,
DROP COLUMN check_in_desk_1,
DROP COLUMN check_in_desk_2,
DROP COLUMN check_in_desk_3,
DROP COLUMN check_in_desk_4;


5. Создание представлений (VIEW), которые будут часто использоваться при анализе

-- Только агенты, работающие в основном составе смены
CREATE VIEW regular_agents AS
SELECT agent_id, agent_name
FROM agents
WHERE agent_role = 'Agent' AND agent_type = 'Regular';

-- Стажеры
CREATE VIEW intern_agents AS
SELECT agent_id, agent_name
FROM agents
WHERE agent_role = 'Intern' AND agent_type = 'Regular';

-- Агенты из дополнительных смен
CREATE VIEW extra_agents AS
SELECT agent_id, agent_name
FROM agents
WHERE agent_type = 'Extra' AND agent_role = 'Agent';

-- Количество агентов на регистрациях 
CREATE VIEW cia_ag_count AS
SELECT shift_flight_id,
COUNT(DISTINCT agent_id) AS cia_ag
FROM flight_assignments
WHERE assignment_type = 'Check_in'
GROUP BY shift_flight_id;

-- Количество агентов на посадках
CREATE VIEW bdg_ag_count AS
SELECT shift_flight_id,
COUNT(DISTINCT agent_id) AS bd_ag
FROM flight_assignments
WHERE assignment_type = 'Boarding'
GROUP BY shift_flight_id;

