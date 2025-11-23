-- Миграция для добавления полной информации об автомобиле в сделки
-- Выполнить: psql -U your_user -d autosalon -f migration_add_car_snapshot_to_deals.sql

-- Добавляем колонки для хранения полной информации об автомобиле в момент сделки
ALTER TABLE deals 
ADD COLUMN IF NOT EXISTS car_brand VARCHAR(100),
ADD COLUMN IF NOT EXISTS car_model VARCHAR(100),
ADD COLUMN IF NOT EXISTS car_year INTEGER,
ADD COLUMN IF NOT EXISTS car_price DECIMAL(12,2),
ADD COLUMN IF NOT EXISTS car_mileage INTEGER,
ADD COLUMN IF NOT EXISTS car_body_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS car_description TEXT,
ADD COLUMN IF NOT EXISTS car_engine_volume DECIMAL(3,1),
ADD COLUMN IF NOT EXISTS car_fuel_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS car_power INTEGER,
ADD COLUMN IF NOT EXISTS car_transmission_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS car_drive_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS car_status VARCHAR(50);

-- Комментарии для понимания структуры
COMMENT ON COLUMN deals.car_brand IS 'Бренд автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_model IS 'Модель автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_year IS 'Год выпуска автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_price IS 'Цена автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_mileage IS 'Пробег автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_body_type IS 'Тип кузова на момент сделки';
COMMENT ON COLUMN deals.car_description IS 'Описание автомобиля на момент сделки';
COMMENT ON COLUMN deals.car_engine_volume IS 'Объем двигателя на момент сделки';
COMMENT ON COLUMN deals.car_fuel_type IS 'Тип топлива на момент сделки';
COMMENT ON COLUMN deals.car_power IS 'Мощность двигателя на момент сделки';
COMMENT ON COLUMN deals.car_transmission_type IS 'Тип трансмиссии на момент сделки';
COMMENT ON COLUMN deals.car_drive_type IS 'Тип привода на момент сделки';
COMMENT ON COLUMN deals.car_status IS 'Статус автомобиля на момент сделки';