-- Создание базы данных для автосалона
-- Выполните этот скрипт через pgAdmin или psql

-- Создание базы данных
CREATE DATABASE autosalon;

-- Подключение к базе данных
\c autosalon;

-- Создание enum типов
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'viewer');
CREATE TYPE car_status AS ENUM ('available', 'sold', 'reserved');
CREATE TYPE deal_type AS ENUM ('sale', 'reservation');
CREATE TYPE deal_status AS ENUM ('new', 'in_process', 'completed', 'canceled');

-- Таблица пользователей (сотрудников)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица автомобилей
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    mileage INTEGER DEFAULT 0,
    body_type VARCHAR(50),
    description TEXT,
    status car_status DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица клиентов
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица сделок
CREATE TABLE deals (
    id SERIAL PRIMARY KEY,
    car_id INTEGER REFERENCES cars(id) ON DELETE CASCADE,
    client_id INTEGER REFERENCES clients(id) ON DELETE CASCADE,
    manager_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    type deal_type NOT NULL,
    status deal_status DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Создание индексов для улучшения производительности
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_brand ON cars(brand);
CREATE INDEX idx_deals_car_id ON deals(car_id);
CREATE INDEX idx_deals_client_id ON deals(client_id);
CREATE INDEX idx_deals_manager_id ON deals(manager_id);

-- Вставка тестовых данных

-- Сотрудники
INSERT INTO users (name, email, password_hash, role) VALUES 
('Администратор Системы', 'admin@autosalon.com', '$2b$10$example_hash_admin', 'admin'),
('Менеджер Иванов', 'manager@autosalon.com', '$2b$10$example_hash_manager', 'manager'),
('Менеджер Петрова', 'petrova@autosalon.com', '$2b$10$example_hash_manager2', 'manager'),
('Наблюдатель Сидоров', 'viewer@autosalon.com', '$2b$10$example_hash_viewer', 'viewer');

-- Автомобили
INSERT INTO cars (brand, model, year, price, mileage, body_type, description, status) VALUES 
('BMW', 'X5', 2020, 7500000.00, 30000, 'SUV', 'Премиальный внедорожник в отличном состоянии', 'available'),
('Mercedes-Benz', 'E-Class', 2021, 6800000.00, 15000, 'Sedan', 'Элегантный седан с комфортной комплектацией', 'available'),
('Audi', 'A4', 2019, 4200000.00, 55000, 'Sedan', 'Надежный автомобиль с хорошей экономичностью', 'sold'),
('Toyota', 'Camry', 2022, 3800000.00, 8000, 'Sedan', 'Японское качество, минимальный пробег', 'available'),
('Honda', 'CR-V', 2020, 3200000.00, 25000, 'SUV', 'Практичный семейный кроссовер', 'reserved'),
('Nissan', 'Altima', 2021, 2900000.00, 18000, 'Sedan', 'Комфортный автомобиль для города', 'available'),
('Hyundai', 'Tucson', 2019, 2200000.00, 45000, 'SUV', 'Доступный кроссовер с хорошей комплектацией', 'available'),
('Kia', 'Sportage', 2022, 2800000.00, 12000, 'SUV', 'Современный дизайн и надежность', 'available');

-- Клиенты
INSERT INTO clients (name, phone, email, notes) VALUES 
('Иван Петров', '+7(999)123-45-67', 'ivan.petrov@email.com', 'Постоянный клиент, предпочитает внедорожники'),
('Мария Сидорова', '+7(999)234-56-78', 'maria.sidorova@email.com', 'Интересуется экологичными автомобилями'),
('Алексей Козлов', '+7(999)345-67-89', 'alexey.kozlov@email.com', 'Покупает автомобили для компании'),
('Елена Волкова', '+7(999)456-78-90', 'elena.volkova@email.com', 'Ищет автомобиль для молодой семьи'),
('Дмитрий Новиков', '+7(999)567-89-01', 'dmitry.novikov@email.com', 'Ценит премиальные марки'),
('Анна Морозова', '+7(999)678-90-12', 'anna.morozova@email.com', 'Первый раз покупает автомобиль'),
('Сергей Лебедев', '+7(999)789-01-23', 'sergey.lebedev@email.com', 'Обмен старого автомобиля'),
('Ольга Федорова', '+7(999)890-12-34', 'olga.fedorova@email.com', 'Ищет экономичный автомобиль');

-- Сделки
INSERT INTO deals (car_id, client_id, manager_id, type, status, completed_at) VALUES 
-- Завершенная продажа
(3, 1, 2, 'sale', 'completed', '2024-11-15 14:30:00'),
-- Активная продажа
(1, 2, 3, 'sale', 'in_process', NULL),
-- Бронирование
(5, 4, 2, 'reservation', 'new', NULL),
-- Новая сделка
(8, 5, 3, 'sale', 'new', NULL);

-- Создание представления для удобного просмотра данных
CREATE VIEW deals_full AS
SELECT 
    d.id,
    d.type,
    d.status,
    d.created_at,
    d.completed_at,
    c.brand || ' ' || c.model as car_name,
    car.price,
    cl.name as client_name,
    cl.phone as client_phone,
    u.name as manager_name
FROM deals d
JOIN cars car ON d.car_id = car.id
JOIN clients cl ON d.client_id = cl.id
LEFT JOIN users u ON d.manager_id = u.id;

-- Создание функции для обновления статуса автомобиля при изменении сделки
CREATE OR REPLACE FUNCTION update_car_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        IF NEW.type = 'sale' THEN
            UPDATE cars SET status = 'sold' WHERE id = NEW.car_id;
        ELSIF NEW.type = 'reservation' THEN
            UPDATE cars SET status = 'available' WHERE id = NEW.car_id;
        END IF;
    END IF;
    
    IF NEW.status = 'in_process' AND OLD.status = 'new' THEN
        IF NEW.type = 'reservation' THEN
            UPDATE cars SET status = 'reserved' WHERE id = NEW.car_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER trigger_update_car_status
    AFTER UPDATE ON deals
    FOR EACH ROW
    EXECUTE FUNCTION update_car_status();

-- Комментарии к таблицам
COMMENT ON TABLE users IS 'Сотрудники автосалона с ролевой системой доступа';
COMMENT ON TABLE cars IS 'Каталог автомобилей в наличии';
COMMENT ON TABLE clients IS 'База клиентов автосалона';
COMMENT ON TABLE deals IS 'Журнал сделок (продажи и бронирования)';

-- Вывод статистики
SELECT 
    'users' as table_name, 
    COUNT(*) as count 
FROM users
UNION ALL
SELECT 
    'cars' as table_name, 
    COUNT(*) as count 
FROM cars
UNION ALL
SELECT 
    'clients' as table_name, 
    COUNT(*) as count 
FROM clients
UNION ALL
SELECT 
    'deals' as table_name, 
    COUNT(*) as count 
FROM deals;
