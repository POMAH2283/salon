-- Миграция для добавления строковых колонок характеристик
-- Выполнить: psql -U your_user -d autosalon -f migration_add_string_characteristics.sql

-- Добавляем строковые колонки для характеристик (если они не существуют)
ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS fuel_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS transmission_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS drive_type VARCHAR(50);

-- Заполняем данные из существующих записей (если есть)
-- Это опционально - можно сделать позже вручную