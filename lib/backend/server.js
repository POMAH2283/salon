import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// PostgreSQL подключение
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'autosalon',
  password: '1234',
  port: 5432,
});

// JWT секреты
const JWT_SECRET = 'your-super-secret-jwt-key-here';
const JWT_REFRESH_SECRET = 'your-super-secret-refresh-key-here';

// Middleware для проверки JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен доступа отсутствует' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Неверный токен' });
    }
    req.user = user;
    next();
  });
};

// РОЛИ И РАЗРЕШЕНИЯ
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Недостаточно прав' });
    }
    next();
  };
};

// АВТОРИЗАЦИЯ
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Находим пользователя
    const userResult = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'Неверный email или пароль' });
    }

    const user = userResult.rows[0];

    // Проверяем пароль (в реальном приложении используем хеширование)
    // Для теста: все пароли "123456"
    const validPassword = password === '123456';

    if (!validPassword) {
      return res.status(401).json({ error: 'Неверный email или пароль' });
    }

    // Создаем JWT токены
    const accessToken = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role
      },
      JWT_SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        created_at: user.created_at
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// ОБНОВЛЕНИЕ ТОКЕНА
app.post('/api/auth/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(401).json({ error: 'Refresh token отсутствует' });
    }

    jwt.verify(refresh_token, JWT_REFRESH_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ error: 'Неверный refresh token' });
      }

      // Получаем пользователя
      const userResult = await pool.query(
        'SELECT * FROM users WHERE id = $1',
        [decoded.userId]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({ error: 'Пользователь не найден' });
      }

      const user = userResult.rows[0];

      const newAccessToken = jwt.sign(
        {
          userId: user.id,
          email: user.email,
          role: user.role
        },
        JWT_SECRET,
        { expiresIn: '15m' }
      );

      res.json({
        access_token: newAccessToken
      });
    });

  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// ВЫХОД
app.post('/api/auth/logout', authenticateToken, (req, res) => {
  res.json({ message: 'Успешный выход' });
});

// АВТОМОБИЛИ
app.get('/api/cars', authenticateToken, async (req, res) => {
  try {
    const { brand, status, min_price, max_price } = req.query;

    let query = 'SELECT * FROM cars WHERE 1=1';
    const params = [];
    let paramCount = 0;

    if (brand) {
      paramCount++;
      query += ` AND brand ILIKE $${paramCount}`;
      params.push(`%${brand}%`);
    }

    if (status) {
      paramCount++;
      query += ` AND status = $${paramCount}`;
      params.push(status);
    }

    if (min_price) {
      paramCount++;
      query += ` AND price >= $${paramCount}`;
      params.push(min_price);
    }

    if (max_price) {
      paramCount++;
      query += ` AND price <= $${paramCount}`;
      params.push(max_price);
    }

    query += ' ORDER BY created_at DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);

  } catch (error) {
    console.error('Get cars error:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// Запуск сервера
app.listen(PORT, () => {
  console.log(`🚗 AutoSalon Server running on port ${PORT}`);
  console.log(`📊 API available at: http://localhost:${PORT}/api`);
});