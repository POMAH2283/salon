-- Миграция для добавления таблицы фотографий автомобилей
-- Выполните: node lib/backend/run_migration.js

-- Создаем таблицу для фотографий автомобилей
CREATE TABLE IF NOT EXISTS car_photos (
    id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL,
    photo_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
);

-- Создаем индекс для быстрого поиска фотографий по автомобилю
CREATE INDEX IF NOT EXISTS idx_car_photos_car_id ON car_photos(car_id);

-- Создаем индекс для первичных фотографий
CREATE INDEX IF NOT EXISTS idx_car_photos_primary ON car_photos(car_id, is_primary) WHERE is_primary = true;

-- Добавляем триггер для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_car_photos_updated_at 
    BEFORE UPDATE ON car_photos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Добавляем комментарии к таблице
COMMENT ON TABLE car_photos IS 'Фотографии автомобилей';
COMMENT ON COLUMN car_photos.id IS 'Уникальный идентификатор фотографии';
COMMENT ON COLUMN car_photos.car_id IS 'ID автомобиля';
COMMENT ON COLUMN car_photos.photo_url IS 'URL или путь к фотографии';
COMMENT ON COLUMN car_photos.is_primary IS 'Является ли фотография основной (главной)';
COMMENT ON COLUMN car_photos.created_at IS 'Дата и время создания записи';
COMMENT ON COLUMN car_photos.updated_at IS 'Дата и время последнего обновления записи';
