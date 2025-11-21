import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function seed() {
  try {
    console.log('🔄 Seeding test data...');

    // Тестовые пользователи
    await pool.query(`
      INSERT INTO users (name, email, password_hash, role) VALUES
      ('Администратор', 'admin@autosalon.ru', '123456', 'admin'),
      ('Менеджер Иван', 'manager@autosalon.ru', '123456', 'manager'),
      ('Наблюдатель', 'viewer@autosalon.ru', '123456', 'viewer')
      ON CONFLICT (email) DO NOTHING;
    `);
    console.log('✅ Users seeded');

    // Тестовые автомобили
    await pool.query(`
      INSERT INTO cars (brand, model, year, price, mileage, body_type, description, status) VALUES
      ('Toyota', 'Camry', 2022, 2500000.00, 15000, 'Седан', 'Комфортный седан бизнес-класса', 'available'),
      ('BMW', 'X5', 2023, 5500000.00, 5000, 'Внедорожник', 'Премиальный внедорожник', 'available'),
      ('Hyundai', 'Solaris', 2021, 1200000.00, 30000, 'Седан', 'Надежный городской седан', 'sold'),
      ('Kia', 'Rio', 2022, 1300000.00, 20000, 'Седан', 'Популярный компактный седан', 'reserved'),
      ('Mercedes-Benz', 'E-Class', 2023, 4800000.00, 10000, 'Седан', 'Роскошный представительский класс', 'available'),
      ('Lada', 'Vesta', 2022, 900000.00, 25000, 'Седан', 'Отечественный надежный автомобиль', 'available')
      ON CONFLICT DO NOTHING;
    `);
    console.log('✅ Cars seeded');

    // Тестовые клиенты
    await pool.query(`
      INSERT INTO clients (name, phone, email, notes) VALUES
      ('Иванов Петр', '+79161234567', 'ivanov@mail.ru', 'Интересуется премиальными авто'),
      ('Сидорова Мария', '+79037654321', 'sidorova@gmail.com', 'Ищет семейный автомобиль'),
      ('Петров Алексей', '+79219876543', 'petrov@yandex.ru', 'Бюджет до 2 млн рублей'),
      ('Козлова Анна', '+79154567890', 'kozlova@mail.ru', 'Интересуется новыми моделями')
      ON CONFLICT DO NOTHING;
    `);
    console.log('✅ Clients seeded');

    console.log('🎉 Test data seeded successfully!');

  } catch (error) {
    console.error('❌ Seeding error:', error.message);
  } finally {
    await pool.end();
  }
}

seed();