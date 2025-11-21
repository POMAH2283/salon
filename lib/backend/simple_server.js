import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 3000;

// CORS middleware
app.use(cors());
app.use(express.json());

// Mock данные
const mockCars = [
  {
    id: 1,
    brand: 'Toyota',
    model: 'Camry',
    year: 2022,
    price: 2500000.00,
    mileage: 15000,
    body_type: 'Седан',
    description: 'Комфортный седан бизнес-класса',
    status: 'available',
    created_at: '2023-01-15T10:00:00Z'
  },
  {
    id: 2,
    brand: 'BMW',
    model: 'X5',
    year: 2023,
    price: 5500000.00,
    mileage: 5000,
    body_type: 'Внедорожник',
    description: 'Премиальный внедорожник',
    status: 'available',
    created_at: '2023-02-20T14:30:00Z'
  }
];

const mockUsers = {
  'admin@autosalon.ru': {
    id: 1,
    name: 'Администратор',
    email: 'admin@autosalon.ru',
    role: 'admin',
    password: '123456'
  },
  'manager@autosalon.ru': {
    id: 2,
    name: 'Менеджер Иван',
    email: 'manager@autosalon.ru',
    role: 'manager',
    password: '123456'
  },
  'viewer@autosalon.ru': {
    id: 3,
    name: 'Наблюдатель',
    email: 'viewer@autosalon.ru',
    role: 'viewer',
    password: '123456'
  }
};

// АВТОРИЗАЦИЯ
app.post('/api/auth/login', (req, res) => {
  console.log('🔐 Login request received');

  try {
    const { email, password } = req.body;
    console.log('Email:', email);

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const user = mockUsers[email];

    if (!user) {
      console.log('User not found:', email);
      return res.status(401).json({ error: 'User not found' });
    }

    if (user.password !== password) {
      console.log('Wrong password for:', email);
      return res.status(401).json({ error: 'Wrong password' });
    }

    const response = {
      access_token: 'mock_jwt_token_' + Date.now(),
      refresh_token: 'mock_refresh_token_' + Date.now(),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        created_at: new Date().toISOString()
      }
    };

    console.log('✅ Login successful:', user.email);
    res.json(response);

  } catch (error) {
    console.error('💥 Login error:', error);
    res.status(500).json({ error: 'Server error: ' + error.message });
  }
});

// ПОЛУЧЕНИЕ АВТОМОБИЛЕЙ
app.get('/api/cars', (req, res) => {
  console.log('🚗 Get cars request');
  res.json(mockCars);
});

// ТЕСТОВЫЙ ENDPOINT
app.get('/api/test', (req, res) => {
  res.json({
    message: '✅ Server is working!',
    timestamp: new Date().toISOString()
  });
});

// ОБНОВЛЕНИЕ ТОКЕНА
app.post('/api/auth/refresh', (req, res) => {
  res.json({
    access_token: 'mock_jwt_token_' + Date.now()
  });
});

// ВЫХОД
app.post('/api/auth/logout', (req, res) => {
  res.json({ message: 'Logged out' });
});

// Запуск сервера
app.listen(PORT, () => {
  console.log('🚀 AutoSalon Server started on http://localhost:' + PORT);
  console.log('📧 Test login: admin@autosalon.ru / 123456');
  console.log('🔗 Test endpoint: http://localhost:' + PORT + '/api/test');
});