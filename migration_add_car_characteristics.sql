-- Миграция для добавления новых характеристик автомобилей
-- Выполнить: psql -U your_user -d autosalon -f migration_add_car_characteristics.sql

-- Таблица типов кузова
CREATE TABLE IF NOT EXISTS body_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов топлива
CREATE TABLE IF NOT EXISTS fuel_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов трансмиссии
CREATE TABLE IF NOT EXISTS transmission_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов привода
CREATE TABLE IF NOT EXISTS drive_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Добавляем новые колонки в таблицу cars
ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS engine_volume DECIMAL(3,1),
ADD COLUMN IF NOT EXISTS fuel_type_id INTEGER,
ADD COLUMN IF NOT EXISTS power INTEGER,
ADD COLUMN IF NOT EXISTS transmission_type_id INTEGER,
ADD COLUMN IF NOT EXISTS drive_type_id INTEGER,
ADD COLUMN IF NOT EXISTS body_type_id INTEGER;

-- Добавляем внешние ключи
ALTER TABLE cars 
ADD CONSTRAINT fk_cars_fuel_type 
FOREIGN KEY (fuel_type_id) REFERENCES fuel_types(id);

ALTER TABLE cars 
ADD CONSTRAINT fk_cars_transmission 
FOREIGN KEY (transmission_type_id) REFERENCES transmission_types(id);

ALTER TABLE cars 
ADD CONSTRAINT fk_cars_drive_type 
FOREIGN KEY (drive_type_id) REFERENCES drive_types(id);

ALTER TABLE cars 
ADD CONSTRAINT fk_cars_body_type 
FOREIGN KEY (body_type_id) REFERENCES body_types(id);

-- Заполняем базовые данные для типов кузова
INSERT INTO body_types (name, description) VALUES
('Седан', 'Автомобиль с четырьмя дверями и багажником отделенным от салона'),
('Хэтчбек', 'Автомобиль с укороченным багажным отделением и задней дверью'),
('Внедорожник', 'Высокий автомобиль с увеличенным дорожным просветом'),
('Кроссовер', 'Легковой автомобиль с элементами внедорожника'),
('Купе', 'Двухдверный автомобиль со спортивным дизайном'),
('Кабриолет', 'Автомобиль с откидным верхом'),
('Минивэн', 'Многофункциональный автомобиль для перевозки пассажиров'),
('Пикап', 'Автомобиль с грузовой платформой'),
('Фургон', 'Автомобиль для перевозки грузов')
ON CONFLICT (name) DO NOTHING;

-- Заполняем базовые данные для типов топлива
INSERT INTO fuel_types (name, description) VALUES
('Бензин', 'Бензиновый двигатель внутреннего сгорания'),
('Дизель', 'Дизельный двигатель'),
('Газ', 'Газовый двигатель'),
('Гибрид', 'Двигатель внутреннего сгорания + электродвигатель'),
('Электричество', 'Полностью электрический двигатель')
ON CONFLICT (name) DO NOTHING;

-- Заполняем базовые данные для типов трансмиссии
INSERT INTO transmission_types (name, description) VALUES
('Механика', 'Механическая коробка передач'),
('Автомат', 'Автоматическая коробка передач'),
('Вариатор', 'Вариаторная коробка передач (CVT)'),
('Робот', 'Роботизированная коробка передач')
ON CONFLICT (name) DO NOTHING;

-- Заполняем базовые данные для типов привода
INSERT INTO drive_types (name, description) VALUES
('Передний', 'Переднеприводный автомобиль'),
('Задний', 'Заднеприводный автомобиль'),
('Полный', 'Полноприводный автомобиль (4WD)'),
('Подключаемый полный', 'Автомобиль с подключаемым полным приводом (AWD)')
ON CONFLICT (name) DO NOTHING;

-- Обновляем API для работы с новыми таблицами
-- Эндпоинты будут доступны по адресам:
-- /api/body-types (GET)
-- /api/fuel-types (GET) 
-- /api/transmission-types (GET)
-- /api/drive-types (GET)