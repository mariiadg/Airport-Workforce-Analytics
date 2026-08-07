-- Структура: 15 таблиц, схема "Снежинка"
-- Справочники: 10 таблиц
-- Операционные: 5 таблиц 

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS airport;
USE airport;

-- СОЗДАНИЕ СПРАВОЧНИКОВ
-- Должности агентов
CREATE TABLE agent_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL
);

-- Тип агента: работает в смене или вызван из другой смены
CREATE TABLE assignment_types (
    assignment_type_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_type VARCHAR(20) NOT NULL
);

-- Авиакомпании
CREATE TABLE airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_name VARCHAR(20),
    airline_code VARCHAR(10) NOT NULL
);

-- Направления
CREATE TABLE destinations (
    destination_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_name VARCHAR(50) NOT NULL
);

-- Системы регистрации (DCS) и их сложность
CREATE TABLE dcs (
    dcs_id INT AUTO_INCREMENT PRIMARY KEY,
    dcs_name VARCHAR(20) NOT NULL,
    dcs_level VARCHAR(20)
);

-- Типы самолётов
CREATE TABLE aircraft_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(20),
    model VARCHAR(20),
    body_type VARCHAR(20)
);

-- Типы рейсов: внутренний или международный
CREATE TABLE flight_types (
    flight_type_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_type VARCHAR(20) NOT NULL
);

-- Стойки регистрации
CREATE TABLE check_in_desks (
    desk_id INT AUTO_INCREMENT PRIMARY KEY,
    desk_number INT NOT NULL,
    terminal VARCHAR(5)
);

-- Смены
CREATE TABLE shifts (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_type VARCHAR(10),
    shift_start DATETIME,
    shift_end DATETIME
);

-- СОЗДАНИЕ ОПЕРАЦИОННЫХ ТАБЛИЦ
-- Рейсы
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT NOT NULL,
    flight_number VARCHAR(10),
    destination_id INT NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (destination_id) REFERENCES destinations(destination_id)
);

-- Агенты
CREATE TABLE agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(10) NOT NULL,
    role_id INT,
    assignment_type_id INT,
    FOREIGN KEY (role_id) REFERENCES agent_roles(role_id),
    FOREIGN KEY (assignment_type_id) REFERENCES assignment_types(assignment_type_id)
);

-- Сырые данные за смену (импорт из CSV)
CREATE TABLE shift_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT,
    shift_start DATETIME,
    shift_end DATETIME,
    shift_type VARCHAR(20),
    airline_id INT,
    flight_number INT,
    destination_id INT,
    flight_type_id INT,
    aircraft_type_id INT,
    dcs_id INT,
    departure_time DATETIME,
    check_in_start DATETIME,
    check_in_close DATETIME,
    boarding_start DATETIME,
    check_in_agent_1 INT DEFAULT 0,
    check_in_agent_2 INT DEFAULT 0,
    check_in_agent_3 INT DEFAULT 0,
    check_in_agent_4 INT DEFAULT 0,
    check_in_agent_5 INT DEFAULT 0,
    boarding_agent_1 INT DEFAULT 0,
    boarding_agent_2 INT DEFAULT 0,
    check_in_desk_1 INT DEFAULT 0,
    check_in_desk_2 INT DEFAULT 0,
    check_in_desk_3 INT DEFAULT 0,
    check_in_desk_4 INT DEFAULT 0,
    pax_total INT,
    shift_handover VARCHAR(20),
    flight_id INT
);
-- Нормализованная связка «смена + рейс»
CREATE TABLE shift_flights (
    shift_flight_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    flight_id INT NOT NULL,
    flight_type_id INT,
    aircraft_type_id INT,
    dcs_id INT,
    departure_time DATETIME,
    check_in_start DATETIME,
    check_in_close DATETIME,
    boarding_start DATETIME,
    pax_total INT,
    shift_handover VARCHAR(10),
    FOREIGN KEY (shift_id) REFERENCES shifts(shift_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (flight_type_id) REFERENCES flight_types(flight_type_id),
    FOREIGN KEY (aircraft_type_id) REFERENCES aircraft_types(type_id),
    FOREIGN KEY (dcs_id) REFERENCES dcs(dcs_id)
);

-- Назначения на регистрацию
CREATE TABLE check_in_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_flight_id INT NOT NULL,
    agent_id INT NOT NULL,
    desk_id INT,
    assignment_type_id INT DEFAULT 1,
    FOREIGN KEY (shift_flight_id) REFERENCES shift_flights(shift_flight_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (desk_id) REFERENCES check_in_desks(desk_id),
    FOREIGN KEY (assignment_type_id) REFERENCES assignment_types(assignment_type_id)
);

-- Назначения на посадку
CREATE TABLE boarding_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_flight_id INT NOT NULL,
    agent_id INT NOT NULL,
    assignment_type_id INT DEFAULT 1,
    FOREIGN KEY (shift_flight_id) REFERENCES shift_flights(shift_flight_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    FOREIGN KEY (assignment_type_id) REFERENCES assignment_types(assignment_type_id)
);
-- Внешние ключи для shift_data
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id);
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_dcs FOREIGN KEY (dcs_id) REFERENCES dcs(dcs_id);
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_flight_type FOREIGN KEY (flight_type_id) REFERENCES flight_types(flight_type_id);
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_aircraft FOREIGN KEY (aircraft_type_id) REFERENCES aircraft_types(type_id);
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_destination FOREIGN KEY (destination_id) REFERENCES destinations(destination_id);
ALTER TABLE shift_data
ADD CONSTRAINT fk_sd_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id);
