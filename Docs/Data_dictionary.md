# Data Dictionary

## Операционные таблицы

### shift_flights

| Поле | Тип | Nullable | Описание | Источник |
|---|---|---|---|---|
| `shift_flight_id` | INT | нет | PK. Уникальный ID рейса в смене | Автоинкремент |
| `shift_id` | INT | нет | FK → `shifts` | Excel |
| `flight_id` | INT | нет | FK → `flights` | Excel |
| `flight_type_id` | INT | нет | FK → `flight_types` | Excel |
| `aircraft_type_id` | INT | нет | FK → `aircraft_types` | Excel |
| `dcs_id` | INT | нет | FK → `dcs` | Excel |
| `departure_time` | DATETIME | нет | Время вылета | Excel |
| `check_in_start` | DATETIME | да | Начало регистрации | Excel |
| `check_in_close` | DATETIME | да | Конец регистрации | Excel |
| `boarding_start` | DATETIME | да | Начало посадки | Excel |
| `pax_total` | INT | да | Всего пассажиров на рейсе | Excel |
| `shift_handover` | VARCHAR(5) | да | Пересменка (да/нет) | Excel |

### flight_assignments

| Поле | Тип | Nullable | Описание | Источник |
|---|---|---|---|---|
| `assignment_id` | INT | нет | PK. ID назначения | Автоинкремент |
| `shift_flight_id` | INT | нет | FK → `shift_flights` | Вычислено |
| `agent_id` | INT | нет | FK → `agents` | Excel |
| `assignment_type` | ENUM | нет | `Check_in` / `Boarding` | Excel |
| `check_in_desk_id` | INT | да | FK → `check_in_desks`. NULL для boarding | Excel |

### flights

| Поле | Тип | Nullable | Описание | Источник |
|---|---|---|---|---|
| `flight_id` | INT | нет | PK. ID рейса | Автоинкремент |
| `airline_id` | INT | нет | FK → `airlines` | Excel |
| `flight_number` | INT | нет | Номер рейса | Excel |
| `destination_id` | INT | нет | FK → `destinations` | Excel |

## Справочники

| Таблица | Поля | Что хранит |
|---|---|---|
| `agents` | `agent_id`, `agent_name`, `agent_role`, `agent_type` | Агенты (56) |
| `airlines` | `airline_id`, `airline_name`, `airline_code` | Авиакомпании (31) |
| `destinations` | `destination_id`, `destination_name` | Направления |
| `dcs` | `dcs_id`, `dcs_name`, `dcs_level` | Системы регистрации (Basic / Medium / Expert) |
| `aircraft_types` | `aircraft_type_id`, `manufacturer`, `model`, `body` | Типы ВС |
| `flight_types` | `flight_type_id`, `flight_type_name` | Domestic / International |
| `check_in_desks` | `check_in_desk_id`, `check_in_desk_number`, `terminal` | Стойки регистрации |
| `shifts` | `shift_id`, `shift_type`, `shift_start`, `shift_end` | Смены |

## Представления (VIEW)

| VIEW | Описание |
|---|---|
| `regular_agents` | Агенты основного состава (`agent_role = 'Agent'`, `agent_type = 'Regular'`) |
| `intern_agents` | Стажёры основного состава |
| `extra_agents` | Дополнительные агенты |
| `cia_ag_count` | Количество check-in агентов на рейс |
| `bdg_ag_count` | Количество boarding агентов на рейс |
