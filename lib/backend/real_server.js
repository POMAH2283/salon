import express from 'express';
import cors from 'cors';
import pkg from 'pg';
const { Pool } = pkg;
import jwt from 'jsonwebtoken';

const app = express();
const PORT = 3000;

// CORS
app.use(cors());
app.use(express.json());

// PostgreSQL подключение
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// JWT секреты
const JWT_SECRET = 'autosalon-super-secret-key-2024';
const JWT_REFRESH_SECRET = 'autosalon-refresh-secret-key-2024';

// Middleware для проверки JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен доступа отсутствует' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.log('❌ JWT verification failed:', err.message);
      return res.status(403).json({ error: 'Неверный токен' });
    }
    req.user = user;
    console.log('✅ JWT verified for user:', user.email);
    next();
  });
};

// Middleware для проверки ролей
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }
    next();
  };
};

// Проверка подключения к базе
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Database connection error:', err);
  } else {
    console.log('✅ Connected to PostgreSQL database: autosalon');
    release();
  }
});

// АВТОРИЗАЦИЯ С БАЗОЙ ДАННЫХ
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('🔐 Login attempt:', email);

    // Ищем пользователя в базе
    const userResult = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (userResult.rows.length === 0) {
      console.log('❌ User not found:', email);
      return res.status(401).json({ error: 'Пользователь не найден' });
    }

    const user = userResult.rows[0];

    // Проверяем пароль
    const validPassword = password === '123456';

    if (!validPassword) {
      console.log('❌ Wrong password for:', email);
      return res.status(401).json({ error: 'Неверный пароль' });
    }

    // Создаем JWT токены
    const accessToken = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    const response = {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        created_at: user.created_at
      }
    };

    console.log('✅ Login successful:', user.email);
    res.json(response);

  } catch (error) {
    console.error('💥 Login error:', error);
    res.status(500).json({ error: 'Ошибка сервера: ' + error.message });
  }
});

// ОБНОВЛЕНИЕ ТОКЕНА
app.post('/api/auth/refresh', (req, res) => {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(401).json({ error: 'Refresh token отсутствует' });
  }

  jwt.verify(refresh_token, JWT_REFRESH_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Неверный refresh token' });
    }

    // Создаем новый access token
    const accessToken = jwt.sign(
      {
        userId: decoded.userId,
        email: decoded.email,
        role: decoded.role
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      access_token: accessToken
    });
  });
});

// ВЫХОД
app.post('/api/auth/logout', authenticateToken, (req, res) => {
  res.json({ message: 'Успешный выход' });
});

// ПОЛУЧЕНИЕ АВТОМОБИЛЕЙ ИЗ БАЗЫ - БЕЗ АУТЕНТИФИКАЦИИ ДЛЯ ТЕСТА
app.get('/api/cars', async (req, res) => {
  try {
    console.log('🚗 Get cars from database');

    const carsResult = await pool.query(`
      SELECT * FROM cars
      ORDER BY created_at DESC
    `);

    console.log(`✅ Found ${carsResult.rows.length} cars`);
    res.json(carsResult.rows);

  } catch (error) {
    console.error('💥 Get cars error:', error);
    res.status(500).json({ error: 'Ошибка получения автомобилей' });
  }
});

// ПОЛУЧЕНИЕ КЛИЕНТОВ ИЗ БАЗЫ - БЕЗ АУТЕНТИФИКАЦИИ ДЛЯ ТЕСТА
app.get('/api/clients', async (req, res) => {
  try {
    const clientsResult = await pool.query(`
      SELECT * FROM clients
      ORDER BY created_at DESC
    `);

    console.log(`✅ Found ${clientsResult.rows.length} clients`);
    res.json(clientsResult.rows);

  } catch (error) {
    console.error('💥 Get clients error:', error);
    res.status(500).json({ error: 'Ошибка получения клиентов' });
  }
});

// ПОЛУЧЕНИЕ СДЕЛОК ИЗ БАЗЫ - БЕЗ АУТЕНТИФИКАЦИИ ДЛЯ ТЕСТА
app.get('/api/deals', async (req, res) => {
  try {
    const dealsResult = await pool.query(`
      SELECT
        d.*,
        c.brand,
        c.model,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      ORDER BY d.created_at DESC
    `);

    console.log(`✅ Found ${dealsResult.rows.length} deals`);
    res.json(dealsResult.rows);

  } catch (error) {
    console.error('💥 Get deals error:', error);
    res.status(500).json({ error: 'Ошибка получения сделок' });
  }
});

// ТЕСТОВЫЙ ENDPOINT С БАЗОЙ - БЕЗ АУТЕНТИФИКАЦИИ ДЛЯ ТЕСТА
app.get('/api/stats', async (req, res) => {
  try {
    const carsCount = await pool.query('SELECT COUNT(*) FROM cars');
    const clientsCount = await pool.query('SELECT COUNT(*) FROM clients');
    const dealsCount = await pool.query('SELECT COUNT(*) FROM deals');
    const usersCount = await pool.query('SELECT COUNT(*) FROM users');

    res.json({
      cars: parseInt(carsCount.rows[0].count),
      clients: parseInt(clientsCount.rows[0].count),
      deals: parseInt(dealsCount.rows[0].count),
      users: parseInt(usersCount.rows[0].count),
      database: 'PostgreSQL'
    });

  } catch (error) {
    console.error('💥 Stats error:', error);
    res.status(500).json({ error: 'Ошибка получения статистики' });
  }
});

// СОЗДАНИЕ АВТОМОБИЛЯ (только admin и manager)
app.post('/api/cars', authenticateToken, async (req, res) => {
  try {
    // Проверяем права (только admin и manager)
    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }

    const { brand, model, year, price, mileage, body_type, description, status } = req.body;

    // Валидация
    if (!brand || !model || !year || !price) {
      return res.status(400).json({ error: 'Обязательные поля: brand, model, year, price' });
    }

    const result = await pool.query(
      `INSERT INTO cars (brand, model, year, price, mileage, body_type, description, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [brand, model, year, price, mileage || 0, body_type || 'Седан', description || '', status || 'available']
    );

    console.log('✅ Car created:', result.rows[0].id);
    res.status(201).json(result.rows[0]);

  } catch (error) {
    console.error('💥 Create car error:', error);
    res.status(500).json({ error: 'Ошибка создания автомобиля' });
  }
});

// ОБНОВЛЕНИЕ АВТОМОБИЛЯ (только admin и manager)
app.put('/api/cars/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }

    const carId = req.params.id;
    const { brand, model, year, price, mileage, body_type, description, status } = req.body;

    const result = await pool.query(
      `UPDATE cars
       SET brand = $1, model = $2, year = $3, price = $4, mileage = $5,
           body_type = $6, description = $7, status = $8
       WHERE id = $9
       RETURNING *`,
      [brand, model, year, price, mileage, body_type, description, status, carId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Автомобиль не найден' });
    }

    console.log('✅ Car updated:', carId);
    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Update car error:', error);
    res.status(500).json({ error: 'Ошибка обновления автомобиля' });
  }
});

// УДАЛЕНИЕ АВТОМОБИЛЯ (только admin)
app.delete('/api/cars/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Только администратор может удалять автомобили' });
    }

    const carId = req.params.id;

    const result = await pool.query('DELETE FROM cars WHERE id = $1 RETURNING *', [carId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Автомобиль не найден' });
    }

    console.log('✅ Car deleted:', carId);
    res.json({ message: 'Автомобиль удален', car: result.rows[0] });

  } catch (error) {
    console.error('💥 Delete car error:', error);
    res.status(500).json({ error: 'Ошибка удаления автомобиля' });
  }
});

// ИЗМЕНЕНИЕ СТАТУСА АВТОМОБИЛЯ (продажа/бронирование)
app.put('/api/cars/:id/status', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }

    const carId = req.params.id;
    const { status } = req.body;

    if (!['available', 'sold', 'reserved'].includes(status)) {
      return res.status(400).json({ error: 'Неверный статус' });
    }

    const result = await pool.query(
      'UPDATE cars SET status = $1 WHERE id = $2 RETURNING *',
      [status, carId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Автомобиль не найден' });
    }

    console.log('✅ Car status updated:', carId, '->', status);
    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Update status error:', error);
    res.status(500).json({ error: 'Ошибка обновления статуса' });
  }
});

// ТЕСТОВЫЙ ENDPOINT ДЛЯ ПРОВЕРКИ СЕРВЕРА
app.get('/api/test', (req, res) => {
  res.json({
    message: '✅ AutoSalon Server is working!',
    timestamp: new Date().toISOString(),
    database: 'PostgreSQL',
    version: '1.0.0'
  });
});

// ПРОСТОЙ ТЕСТ БАЗЫ
app.get('/api/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT 1 as test');
    res.json({
      status: '✅ Database connected',
      test: result.rows[0].test,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: '❌ Database error',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// ПОЛУЧЕНИЕ ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ
app.get('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    const userResult = await pool.query(
      'SELECT id, name, email, role, created_at FROM users WHERE id = $1',
      [req.user.userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'Пользователь не найден' });
    }

    res.json(userResult.rows[0]);
  } catch (error) {
    console.error('💥 Get user profile error:', error);
    res.status(500).json({ error: 'Ошибка получения профиля' });
  }
});

// Запуск сервера
app.listen(PORT, () => {
  console.log('🚀 AutoSalon Server with PostgreSQL started!');
  console.log('📍 Port:', PORT);
  console.log('🗄️ Database: PostgreSQL (autosalon)');
  console.log('🔑 DB Password: Admin');
  console.log('🔗 Test endpoints:');
  console.log('   http://localhost:' + PORT + '/api/test');
  console.log('   http://localhost:' + PORT + '/api/db-test');
  console.log('   http://localhost:' + PORT + '/api/stats');
  console.log('   http://localhost:' + PORT + '/api/cars');
  console.log('📧 Test users:');
  console.log('   admin@autosalon.ru / 123456 (Admin)');
  console.log('   manager@autosalon.ru / 123456 (Manager)');
  console.log('   viewer@autosalon.ru / 123456 (Viewer)');
  console.log('');
  console.log('💡 GET endpoints работают без аутентификации');
  console.log('💡 POST/PUT/DELETE endpoints требуют JWT токен');
  console.log('');
});