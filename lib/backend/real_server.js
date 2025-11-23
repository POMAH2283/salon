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

// РЕГИСТРАЦИЯ ПОЛЬЗОВАТЕЛЯ
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    console.log('📝 Registration attempt:', email);

    // Валидация
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Все поля обязательны: name, email, password' });
    }

    // Проверяем, существует ли пользователь с таким email
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      console.log('❌ User already exists:', email);
      return res.status(409).json({ error: 'Пользователь с таким email уже существует' });
    }

    // Создаем нового пользователя
    console.log('🔍 Registering user with password:', password);
    const newUser = await pool.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role, created_at`,
      [name, email, password, 'viewer'] // По умолчанию роль viewer
    );

    const user = newUser.rows[0];
    console.log('✅ User registered:', user.email);
    console.log('✅ User password hash in DB:', user.password_hash);

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

    res.status(201).json(response);

  } catch (error) {
    console.error('💥 Registration error:', error);
    res.status(500).json({ error: 'Ошибка сервера: ' + error.message });
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

    console.log('🔍 User found:', user.email);
    console.log('🔍 Stored password hash:', user.password_hash);
    console.log('🔍 Input password:', password);

    // Проверяем пароль (простое сравнение для демо)
    // В реальном приложении нужно использовать bcrypt для хеширования
    const storedPassword = user.password_hash;
    const validPassword = password === storedPassword;

    console.log('🔍 Password comparison result:', validPassword);

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

// ПОЛУЧЕНИЕ АВТОМОБИЛЕЙ С ФИЛЬТРАЦИЕЙ
app.get('/api/cars', async (req, res) => {
  try {
    console.log('🚗 Get cars from database with filters');

    const { 
      status, 
      sort_by, 
      sort_order,
      brand,
      body_type,
      fuel_type,
      transmission_type,
      drive_type,
      year_min,
      year_max,
      price_min,
      price_max,
      mileage_min,
      mileage_max,
      engine_volume_min,
      engine_volume_max,
      power_min,
      power_max
    } = req.query;
    
    let query = 'SELECT * FROM cars WHERE 1=1';
    const params = [];
    
    // Фильтр по статусу
    if (status && status !== 'all') {
      params.push(status);
      query += ` AND status = ${params.length}`;
    }
    
    // Фильтр по бренду
    if (brand && brand !== 'all') {
      params.push(brand);
      query += ` AND brand = ${params.length}`;
    }
    
    // Фильтр по типу кузова
    if (body_type && body_type !== 'all') {
      params.push(body_type);
      query += ` AND body_type = ${params.length}`;
    }
    
    // Фильтр по типу топлива
    if (fuel_type && fuel_type !== 'all') {
      params.push(fuel_type);
      query += ` AND fuel_type = ${params.length}`;
    }
    
    // Фильтр по трансмиссии
    if (transmission_type && transmission_type !== 'all') {
      params.push(transmission_type);
      query += ` AND transmission_type = ${params.length}`;
    }
    
    // Фильтр по приводу
    if (drive_type && drive_type !== 'all') {
      params.push(drive_type);
      query += ` AND drive_type = ${params.length}`;
    }
    
    // Диапазон года
    if (year_min) {
      params.push(parseInt(year_min));
      query += ` AND year >= ${params.length}`;
    }
    if (year_max) {
      params.push(parseInt(year_max));
      query += ` AND year <= ${params.length}`;
    }
    
    // Диапазон цены
    if (price_min) {
      params.push(parseFloat(price_min));
      query += ` AND price >= ${params.length}`;
    }
    if (price_max) {
      params.push(parseFloat(price_max));
      query += ` AND price <= ${params.length}`;
    }
    
    // Диапазон пробега
    if (mileage_min) {
      params.push(parseInt(mileage_min));
      query += ` AND mileage >= ${params.length}`;
    }
    if (mileage_max) {
      params.push(parseInt(mileage_max));
      query += ` AND mileage <= ${params.length}`;
    }
    
    // Диапазон объема двигателя
    if (engine_volume_min) {
      params.push(parseFloat(engine_volume_min));
      query += ` AND engine_volume >= ${params.length}`;
    }
    if (engine_volume_max) {
      params.push(parseFloat(engine_volume_max));
      query += ` AND engine_volume <= ${params.length}`;
    }
    
    // Диапазон мощности
    if (power_min) {
      params.push(parseInt(power_min));
      query += ` AND power >= ${params.length}`;
    }
    if (power_max) {
      params.push(parseInt(power_max));
      query += ` AND power <= ${params.length}`;
    }
    
    query += ' ORDER BY created_at DESC';
    
    // Сортировка
    if (sort_by) {
      const order = sort_order === 'desc' ? 'DESC' : 'ASC';
      switch (sort_by) {
        case 'price':
          query = query.replace('ORDER BY created_at DESC', `ORDER BY price ${order}`);
          break;
        case 'year':
          query = query.replace('ORDER BY created_at DESC', `ORDER BY year ${order}`);
          break;
        case 'mileage':
          query = query.replace('ORDER BY created_at DESC', `ORDER BY mileage ${order}`);
          break;
        case 'brand':
          query = query.replace('ORDER BY created_at DESC', `ORDER BY brand ${order}`);
          break;
        case 'created_at':
          // Default ordering
          break;
        default:
          query = query.replace('ORDER BY created_at DESC', `ORDER BY ${sort_by} ${order}`);
      }
    }

    const carsResult = await pool.query(query, params);
    console.log(`✅ Found ${carsResult.rows.length} cars`);
    res.json(carsResult.rows);

  } catch (error) {
    console.error('💥 Get cars error:', error);
    res.status(500).json({ error: 'Ошибка получения автомобилей' });
  }
});

// ПОЛУЧЕНИЕ ДОСТУПНЫХ АВТОМОБИЛЕЙ (только со статусом 'available')
app.get('/api/cars/available', async (req, res) => {
  try {
    console.log('🚗 Get available cars from database');

    const carsResult = await pool.query(`
      SELECT * FROM cars
      WHERE status = 'available'
      ORDER BY created_at DESC
    `);

    console.log(`✅ Found ${carsResult.rows.length} available cars`);
    res.json(carsResult.rows);

  } catch (error) {
    console.error('💥 Get available cars error:', error);
    res.status(500).json({ error: 'Ошибка получения доступных автомобилей' });
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

// ПОЛУЧЕНИЕ МЕНЕДЖЕРОВ ИЗ БАЗЫ
app.get('/api/managers', async (req, res) => {
  try {
    const managersResult = await pool.query(`
      SELECT id, name, email, role 
      FROM users 
      WHERE role IN ('admin', 'manager')
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${managersResult.rows.length} managers`);
    res.json(managersResult.rows);

  } catch (error) {
    console.error('💥 Get managers error:', error);
    res.status(500).json({ error: 'Ошибка получения менеджеров' });
  }
});

// ПОЛУЧЕНИЕ СДЕЛОК ИЗ БАЗЫ - БЕЗ АУТЕНТИФИКАЦИИ ДЛЯ ТЕСТА
app.get('/api/deals', async (req, res) => {
  try {
    const dealsResult = await pool.query(`
      SELECT
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
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

    const { 
      brand, model, year, price, mileage, body_type, description, status,
      engine_volume, fuel_type, power, transmission_type, drive_type
    } = req.body;

    // Валидация
    if (!brand || !model || !year || !price) {
      return res.status(400).json({ error: 'Обязательные поля: brand, model, year, price' });
    }

    // Build INSERT query - ALL fields included, like existing ones
    const result = await pool.query(
      `INSERT INTO cars (brand, model, year, price, mileage, body_type, description, status, engine_volume, fuel_type, power, transmission_type, drive_type) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) 
       RETURNING *`,
      [brand, model, year, price, mileage || 0, body_type || 'Седан', description || '', status || 'available',
       engine_volume || null, fuel_type || null, power || null, transmission_type || null, drive_type || null]
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
    const { 
      brand, model, year, price, mileage, body_type, description, status,
      engine_volume, fuel_type, power, transmission_type, drive_type
    } = req.body;

    // Build UPDATE query - ALL fields included, like existing ones
    const result = await pool.query(
      `UPDATE cars SET 
        brand = $1, 
        model = $2, 
        year = $3, 
        price = $4, 
        mileage = $5, 
        body_type = $6, 
        description = $7, 
        status = $8,
        engine_volume = $9,
        fuel_type = $10,
        power = $11,
        transmission_type = $12,
        drive_type = $13
      WHERE id = $14 
      RETURNING *`,
      [brand, model, year, price, mileage, body_type, description, status, 
       engine_volume || null, fuel_type || null, power || null, transmission_type || null, drive_type || null, carId]
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

// ПОЛУЧЕНИЕ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ (для отладки)
app.get('/api/users', async (req, res) => {
  try {
    const usersResult = await pool.query(
      'SELECT id, name, email, role, created_at FROM users ORDER BY created_at DESC'
    );

    console.log(`✅ Found ${usersResult.rows.length} users`);
    res.json(usersResult.rows);

  } catch (error) {
    console.error('💥 Get users error:', error);
    res.status(500).json({ error: 'Ошибка получения пользователей' });
  }
});

// СОЗДАНИЕ КЛИЕНТА
app.post('/api/clients', authenticateToken, async (req, res) => {
  try {
    const { name, phone, email, notes } = req.body;

    // Валидация
    if (!name) {
      return res.status(400).json({ error: 'Имя клиента обязательно' });
    }

    const result = await pool.query(
      `INSERT INTO clients (name, phone, email, notes)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [name, phone, email, notes]
    );

    console.log('✅ Client created:', result.rows[0].id);
    res.status(201).json(result.rows[0]);

  } catch (error) {
    console.error('💥 Create client error:', error);
    res.status(500).json({ error: 'Ошибка создания клиента' });
  }
});

// СОЗДАНИЕ КЛИЕНТА И СДЕЛКИ (комбинированная операция)
app.post('/api/deals/with-client', authenticateToken, async (req, res) => {
  try {
    const { carId, clientName, managerId, type } = req.body;

    // Валидация
    if (!carId || !clientName || !managerId || !type) {
      return res.status(400).json({ error: 'Обязательные поля: carId, clientName, managerId, type' });
    }

    if (!['sale', 'reservation'].includes(type)) {
      return res.status(400).json({ error: 'Неверный тип сделки' });
    }

    // Начинаем транзакцию
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      // 1. Создаем клиента
      const clientResult = await client.query(
        `INSERT INTO clients (name) VALUES ($1) RETURNING *`,
        [clientName.trim()]
      );
      
      const newClient = clientResult.rows[0];
      console.log('✅ Client created for deal:', newClient.id);
      
      // 2. Получаем полную информацию об автомобиле
      const carResult = await client.query('SELECT * FROM cars WHERE id = $1', [carId]);
      if (carResult.rows.length === 0) {
        throw new Error('Автомобиль не найден');
      }
      const car = carResult.rows[0];
      
      // 3. Создаем сделку с полной информацией об автомобиле
      const dealResult = await client.query(
        `INSERT INTO deals (
          car_id, client_id, manager_id, type, status,
          car_brand, car_model, car_year, car_price, car_mileage, car_body_type, car_description,
          car_engine_volume, car_fuel_type, car_power, car_transmission_type, car_drive_type, car_status
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
         RETURNING *`,
        [
          carId, newClient.id, managerId, type, 'new',
          car.brand, car.model, car.year, car.price, car.mileage, car.body_type, car.description,
          car.engine_volume, car.fuel_type, car.power, car.transmission_type, car.drive_type, car.status
        ]
      );
      
      const newDeal = dealResult.rows[0];
      console.log('✅ Deal created:', newDeal.id);
      
      // 4. Обновляем статус автомобиля
      const carStatus = type === 'sale' ? 'sold' : 'reserved';
      await client.query(
        'UPDATE cars SET status = $1 WHERE id = $2',
        [carStatus, carId]
      );
      console.log('✅ Car status updated to:', carStatus);
      
      await client.query('COMMIT');
      
      // Возвращаем сделку с дополнительными данными
      const enrichedDealResult = await pool.query(`
        SELECT 
          d.*,
          c.brand || ' ' || c.model as car_name,
          c.price,
          cl.name as client_name,
          u.name as manager_name
        FROM deals d
        LEFT JOIN cars c ON d.car_id = c.id
        LEFT JOIN clients cl ON d.client_id = cl.id
        LEFT JOIN users u ON d.manager_id = u.id
        WHERE d.id = $1
      `, [newDeal.id]);
      
      res.status(201).json(enrichedDealResult.rows[0]);

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }

  } catch (error) {
    console.error('💥 Create deal with client error:', error);
    res.status(500).json({ error: 'Ошибка создания сделки с клиентом' });
  }
});

// ПОЛУЧЕНИЕ КЛИЕНТА ПО ID
app.get('/api/clients/:id', authenticateToken, async (req, res) => {
  try {
    const clientId = req.params.id;
    const result = await pool.query('SELECT * FROM clients WHERE id = $1', [clientId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Клиент не найден' });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Get client error:', error);
    res.status(500).json({ error: 'Ошибка получения клиента' });
  }
});

// ОБНОВЛЕНИЕ КЛИЕНТА
app.put('/api/clients/:id', authenticateToken, async (req, res) => {
  try {
    const clientId = req.params.id;
    const { name, phone, email, notes } = req.body;

    const result = await pool.query(
      `UPDATE clients
       SET name = $1, phone = $2, email = $3, notes = $4
       WHERE id = $5
       RETURNING *`,
      [name, phone, email, notes, clientId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Клиент не найден' });
    }

    console.log('✅ Client updated:', clientId);
    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Update client error:', error);
    res.status(500).json({ error: 'Ошибка обновления клиента' });
  }
});

// УДАЛЕНИЕ КЛИЕНТА
app.delete('/api/clients/:id', authenticateToken, async (req, res) => {
  try {
    const clientId = req.params.id;

    const result = await pool.query('DELETE FROM clients WHERE id = $1 RETURNING *', [clientId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Клиент не найден' });
    }

    console.log('✅ Client deleted:', clientId);
    res.json({ message: 'Клиент удален', client: result.rows[0] });

  } catch (error) {
    console.error('💥 Delete client error:', error);
    res.status(500).json({ error: 'Ошибка удаления клиента' });
  }
});

// СОЗДАНИЕ СДЕЛКИ
app.post('/api/deals', authenticateToken, async (req, res) => {
  try {
    const { car_id, client_id, manager_id, type } = req.body;

    // Валидация
    if (!car_id || !client_id || !manager_id || !type) {
      return res.status(400).json({ error: 'Обязательные поля: car_id, client_id, manager_id, type' });
    }

    if (!['sale', 'reservation'].includes(type)) {
      return res.status(400).json({ error: 'Неверный тип сделки' });
    }

    // Начинаем транзакцию
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      // Получаем полную информацию об автомобиле для сохранения в сделке
      const carResult = await client.query('SELECT * FROM cars WHERE id = $1', [car_id]);
      if (carResult.rows.length === 0) {
        throw new Error('Автомобиль не найден');
      }
      const car = carResult.rows[0];

      // Создаем сделку с полной информацией об автомобиле
      const dealResult = await client.query(
        `INSERT INTO deals (
          car_id, client_id, manager_id, type, status,
          car_brand, car_model, car_year, car_price, car_mileage, car_body_type, car_description,
          car_engine_volume, car_fuel_type, car_power, car_transmission_type, car_drive_type, car_status
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
         RETURNING *`,
        [
          car_id, client_id, manager_id, type, 'new',
          car.brand, car.model, car.year, car.price, car.mileage, car.body_type, car.description,
          car.engine_volume, car.fuel_type, car.power, car.transmission_type, car.drive_type, car.status
        ]
      );
      
      const newDeal = dealResult.rows[0];
      
      // Обновляем статус автомобиля
      const carStatus = type === 'sale' ? 'sold' : 'reserved';
      await client.query(
        'UPDATE cars SET status = $1 WHERE id = $2',
        [carStatus, car_id]
      );
      
      await client.query('COMMIT');
      
      console.log('✅ Deal created:', newDeal.id, '- Car status updated to:', carStatus);
      res.status(201).json(newDeal);
      
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }

  } catch (error) {
    console.error('💥 Create deal error:', error);
    res.status(500).json({ error: 'Ошибка создания сделки' });
  }
});

// ПОЛУЧЕНИЕ СДЕЛКИ ПО ID
app.get('/api/deals/:id', authenticateToken, async (req, res) => {
  try {
    const dealId = req.params.id;
    const result = await pool.query(`
      SELECT 
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      WHERE d.id = $1
    `, [dealId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Get deal error:', error);
    res.status(500).json({ error: 'Ошибка получения сделки' });
  }
});

// ОБНОВЛЕНИЕ СДЕЛКИ
app.put('/api/deals/:id', authenticateToken, async (req, res) => {
  try {
    const dealId = req.params.id;
    const { car_id, client_id, manager_id, type, status } = req.body;

    const result = await pool.query(
      `UPDATE deals
       SET car_id = $1, client_id = $2, manager_id = $3, type = $4, status = $5
       WHERE id = $6
       RETURNING *`,
      [car_id, client_id, manager_id, type, status, dealId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    // Получаем обновленную сделку с дополнительными данными
    const enrichedResult = await pool.query(`
      SELECT 
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      WHERE d.id = $1
    `, [dealId]);

    console.log('✅ Deal updated:', dealId);
    res.json(enrichedResult.rows[0]);

  } catch (error) {
    console.error('💥 Update deal error:', error);
    res.status(500).json({ error: 'Ошибка обновления сделки' });
  }
});

// ОБНОВЛЕНИЕ СТАТУСА СДЕЛКИ
app.put('/api/deals/:id/status', authenticateToken, async (req, res) => {
  try {
    const dealId = req.params.id;
    const { status } = req.body;

    if (!['new', 'in_process', 'completed', 'canceled'].includes(status)) {
      return res.status(400).json({ error: 'Неверный статус' });
    }

    const result = await pool.query(
      `UPDATE deals 
       SET status = $1, completed_at = $2
       WHERE id = $3
       RETURNING *`,
      [status, status === 'completed' ? new Date() : null, dealId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    // Получаем обновленную сделку с дополнительными данными
    const enrichedResult = await pool.query(`
      SELECT 
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      WHERE d.id = $1
    `, [dealId]);

    console.log('✅ Deal status updated:', dealId, '->', status);
    res.json(enrichedResult.rows[0]);

  } catch (error) {
    console.error('💥 Update deal status error:', error);
    res.status(500).json({ error: 'Ошибка обновления статуса сделки' });
  }
});

// ЗАВЕРШЕНИЕ СДЕЛКИ
app.put('/api/deals/:id/complete', authenticateToken, async (req, res) => {
  try {
    const dealId = req.params.id;

    const result = await pool.query(
      `UPDATE deals 
       SET status = 'completed', completed_at = $1
       WHERE id = $2
       RETURNING *`,
      [new Date(), dealId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    // Получаем завершенную сделку с дополнительными данными
    const enrichedResult = await pool.query(`
      SELECT 
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      WHERE d.id = $1
    `, [dealId]);

    console.log('✅ Deal completed:', dealId);
    res.json(enrichedResult.rows[0]);

  } catch (error) {
    console.error('💥 Complete deal error:', error);
    res.status(500).json({ error: 'Ошибка завершения сделки' });
  }
});

// ОТМЕНА СДЕЛКИ
app.put('/api/deals/:id/cancel', authenticateToken, async (req, res) => {
  try {
    const dealId = req.params.id;

    const result = await pool.query(
      `UPDATE deals 
       SET status = 'canceled', completed_at = $1
       WHERE id = $2
       RETURNING *`,
      [new Date(), dealId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    // Получаем отмененную сделку с дополнительными данными
    const enrichedResult = await pool.query(`
      SELECT 
        d.*,
        c.brand || ' ' || c.model as car_name,
        c.price,
        cl.name as client_name,
        u.name as manager_name
      FROM deals d
      LEFT JOIN cars c ON d.car_id = c.id
      LEFT JOIN clients cl ON d.client_id = cl.id
      LEFT JOIN users u ON d.manager_id = u.id
      WHERE d.id = $1
    `, [dealId]);

    console.log('✅ Deal cancelled:', dealId);
    res.json(enrichedResult.rows[0]);

  } catch (error) {
    console.error('💥 Cancel deal error:', error);
    res.status(500).json({ error: 'Ошибка отмены сделки' });
  }
});

// УДАЛЕНИЕ СДЕЛКИ (только admin)
app.delete('/api/deals/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Только администратор может удалять сделки' });
    }

    const dealId = req.params.id;

    const result = await pool.query('DELETE FROM deals WHERE id = $1 RETURNING *', [dealId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Сделка не найдена' });
    }

    console.log('✅ Deal deleted:', dealId);
    res.json({ message: 'Сделка удалена', deal: result.rows[0] });

  } catch (error) {
    console.error('💥 Delete deal error:', error);
    res.status(500).json({ error: 'Ошибка удаления сделки' });
  }
});

// ============= BRANDS API =============

// ПОЛУЧЕНИЕ ВСЕХ МАРОК
app.get('/api/brands', async (req, res) => {
  try {
    const brandsResult = await pool.query(`
      SELECT * FROM brands
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${brandsResult.rows.length} brands`);
    res.json(brandsResult.rows);

  } catch (error) {
    console.error('💥 Get brands error:', error);
    res.status(500).json({ error: 'Ошибка получения марок' });
  }
});

// СОЗДАНИЕ МАРКИ (только admin и manager)
app.post('/api/brands', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }

    const { name } = req.body;

    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Название марки обязательно' });
    }

    // Проверяем, существует ли марка
    const existingBrand = await pool.query(
      'SELECT id FROM brands WHERE LOWER(name) = LOWER($1)',
      [name.trim()]
    );

    if (existingBrand.rows.length > 0) {
      return res.status(409).json({ error: 'Марка с таким названием уже существует' });
    }

    const result = await pool.query(
      `INSERT INTO brands (name) VALUES ($1) RETURNING *`,
      [name.trim()]
    );

    console.log('✅ Brand created:', result.rows[0].id);
    res.status(201).json(result.rows[0]);

  } catch (error) {
    console.error('💥 Create brand error:', error);
    res.status(500).json({ error: 'Ошибка создания марки' });
  }
});

// ОБНОВЛЕНИЕ МАРКИ (только admin)
app.put('/api/brands/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Только администратор может редактировать марки' });
    }

    const brandId = req.params.id;
    const { name } = req.body;

    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Название марки обязательно' });
    }

    const result = await pool.query(
      `UPDATE brands SET name = $1 WHERE id = $2 RETURNING *`,
      [name.trim(), brandId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Марка не найдена' });
    }

    console.log('✅ Brand updated:', brandId);
    res.json(result.rows[0]);

  } catch (error) {
    console.error('💥 Update brand error:', error);
    res.status(500).json({ error: 'Ошибка обновления марки' });
  }
});

// УДАЛЕНИЕ МАРКИ (только admin)
app.delete('/api/brands/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Только администратор может удалять марки' });
    }

    const brandId = req.params.id;

    // Проверяем, используется ли марка в автомобилях
    const carsWithBrand = await pool.query(
      'SELECT COUNT(*) FROM cars WHERE brand = (SELECT name FROM brands WHERE id = $1)',
      [brandId]
    );

    if (parseInt(carsWithBrand.rows[0].count) > 0) {
      return res.status(400).json({ 
        error: 'Невозможно удалить марку, так как она используется в автомобилях' 
      });
    }

    const result = await pool.query('DELETE FROM brands WHERE id = $1 RETURNING *', [brandId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Марка не найдена' });
    }

    console.log('✅ Brand deleted:', brandId);
    res.json({ message: 'Марка удалена', brand: result.rows[0] });

  } catch (error) {
    console.error('💥 Delete brand error:', error);
    res.status(500).json({ error: 'Ошибка удаления марки' });
  }
});

// ПОЛУЧЕНИЕ ТИПОВ ТОПЛИВА
app.get('/api/fuel-types', async (req, res) => {
  try {
    const fuelTypesResult = await pool.query(`
      SELECT * FROM fuel_types
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${fuelTypesResult.rows.length} fuel types`);
    res.json(fuelTypesResult.rows);

  } catch (error) {
    console.error('💥 Get fuel types error:', error);
    res.status(500).json({ error: 'Ошибка получения типов топлива' });
  }
});

// ПОЛУЧЕНИЕ ТИПОВ ТРАНСМИССИИ
app.get('/api/transmission-types', async (req, res) => {
  try {
    const transmissionTypesResult = await pool.query(`
      SELECT * FROM transmission_types
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${transmissionTypesResult.rows.length} transmission types`);
    res.json(transmissionTypesResult.rows);

  } catch (error) {
    console.error('💥 Get transmission types error:', error);
    res.status(500).json({ error: 'Ошибка получения типов трансмиссии' });
  }
});

// ПОЛУЧЕНИЕ ТИПОВ ПРИВОДА
app.get('/api/drive-types', async (req, res) => {
  try {
    const driveTypesResult = await pool.query(`
      SELECT * FROM drive_types
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${driveTypesResult.rows.length} drive types`);
    res.json(driveTypesResult.rows);

  } catch (error) {
    console.error('💥 Get drive types error:', error);
    res.status(500).json({ error: 'Ошибка получения типов привода' });
  }
});

// ПОЛУЧЕНИЕ ТИПОВ КУЗОВА
app.get('/api/body-types', async (req, res) => {
  try {
    const bodyTypesResult = await pool.query(`
      SELECT * FROM body_types
      ORDER BY name ASC
    `);

    console.log(`✅ Found ${bodyTypesResult.rows.length} body types`);
    res.json(bodyTypesResult.rows);

  } catch (error) {
    console.error('💥 Get body types error:', error);
    res.status(500).json({ error: 'Ошибка получения типов кузова' });
  }
});

// Запуск сервера
app.listen(PORT, () => {
  console.log('🚀 AutoSalon Server with PostgreSQL started!');
  console.log('📍 Port:', PORT);
  console.log('🗄️ Database: PostgreSQL (autosalon)');
  console.log('🔗 Test endpoints:');
  console.log('   http://localhost:' + PORT + '/api/test');
  console.log('   http://localhost:' + PORT + '/api/db-test');
  console.log('   http://localhost:' + PORT + '/api/stats');
  console.log('   http://localhost:' + PORT + '/api/cars');
  console.log('   http://localhost:' + PORT + '/api/auth/register');
  console.log('   http://localhost:' + PORT + '/api/auth/login');
  console.log('📧 Registration: POST /api/auth/register with name, email, password');
  console.log('📧 Login: POST /api/auth/login with email, password (default password: 123456)');
  console.log('');
  console.log('💡 GET endpoints работают без аутентификации');
  console.log('💡 POST/PUT/DELETE endpoints требуют JWT токен');
  console.log('');
});
