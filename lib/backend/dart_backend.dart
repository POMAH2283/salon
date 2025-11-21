import 'dart:io';
import 'dart:convert';

// Простой HTTP сервер на Dart - не требует Node.js!
void main() async {
  final server = await HttpServer.bind('localhost', 3000);
  print('🚗 AutoSalon Dart Server running on http://localhost:3000');

  await for (HttpRequest request in server) {
    _handleRequest(request);
  }
}

void _handleRequest(HttpRequest request) {
  // CORS headers
  request.response.headers.add('Access-Control-Allow-Origin', '*');
  request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (request.method == 'OPTIONS') {
    request.response.statusCode = 200;
    request.response.close();
    return;
  }

  try {
    final path = request.uri.path;
    print('Request: ${request.method} $path');

    if (path == '/api/auth/login' && request.method == 'POST') {
      _handleLogin(request);
    } else if (path == '/api/cars' && request.method == 'GET') {
      _handleGetCars(request);
    } else {
      request.response.statusCode = 404;
      request.response.write(json.encode({'error': 'Not found'}));
      request.response.close();
    }
  } catch (e) {
    request.response.statusCode = 500;
    request.response.write(json.encode({'error': 'Server error: $e'}));
    request.response.close();
  }
}

void _handleLogin(HttpRequest request) async {
  try {
    final body = await utf8.decoder.bind(request).join();
    final data = json.decode(body) as Map<String, dynamic>;

    final email = data['email'] as String?;
    final password = data['password'] as String?;

    // Тестовые пользователи
    final testUsers = {
      'admin@autosalon.ru': {'password': '123456', 'role': 'admin', 'name': 'Администратор', 'id': 1},
      'manager@autosalon.ru': {'password': '123456', 'role': 'manager', 'name': 'Менеджер Иван', 'id': 2},
      'viewer@autosalon.ru': {'password': '123456', 'role': 'viewer', 'name': 'Наблюдатель', 'id': 3},
    };

    if (email != null &&
        testUsers.containsKey(email) &&
        testUsers[email]!['password'] == password) {

      final user = testUsers[email]!;
      final userResponse = {
        'id': user['id'],
        'name': user['name'],
        'email': email,
        'role': user['role'],
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = {
        'access_token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': userResponse,
      };

      request.response.statusCode = 200;
      request.response.write(json.encode(response));
    } else {
      request.response.statusCode = 401;
      request.response.write(json.encode({'error': 'Неверный email или пароль'}));
    }
  } catch (e) {
    request.response.statusCode = 500;
    request.response.write(json.encode({'error': 'Login error: $e'}));
  }

  await request.response.close();
}

void _handleGetCars(HttpRequest request) {
  final mockCars = [
    {
      'id': 1,
      'brand': 'Toyota',
      'model': 'Camry',
      'year': 2022,
      'price': 2500000.00,
      'mileage': 15000,
      'body_type': 'Седан',
      'description': 'Комфортный седан бизнес-класса',
      'status': 'available',
      'created_at': '2023-01-15T10:00:00Z'
    },
    {
      'id': 2,
      'brand': 'BMW',
      'model': 'X5',
      'year': 2023,
      'price': 5500000.00,
      'mileage': 5000,
      'body_type': 'Внедорожник',
      'description': 'Премиальный внедорожник',
      'status': 'available',
      'created_at': '2023-02-20T14:30:00Z'
    },
    {
      'id': 3,
      'brand': 'Hyundai',
      'model': 'Solaris',
      'year': 2021,
      'price': 1200000.00,
      'mileage': 30000,
      'body_type': 'Седан',
      'description': 'Надежный городской седан',
      'status': 'sold',
      'created_at': '2023-03-10T09:15:00Z'
    }
  ];

  request.response.statusCode = 200;
  request.response.write(json.encode(mockCars));
  request.response.close();
}