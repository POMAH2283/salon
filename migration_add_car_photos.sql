-- Добавление поля photos в таблицу cars для хранения URL фотографий
ALTER TABLE cars 
ADD COLUMN photos JSONB DEFAULT '[]'::jsonb;

-- Создание индекса для быстрого поиска
-- Используем jsonb_path_ops для лучшей производительности при поиске
CREATE INDEX idx_cars_photos ON cars USING GIN (photos jsonb_path_ops);

-- Комментарий для документации
COMMENT ON COLUMN cars.photos IS 'JSON массив URL фотографий автомобиля';

-- Пример обновления существующих записей (пустой массив по умолчанию)
-- UPDATE cars SET photos = '[]'::json WHERE photos IS NULL;