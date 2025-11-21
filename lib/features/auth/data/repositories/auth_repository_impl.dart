import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/api_service.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  // Конструктор без параметров
  AuthRepositoryImpl()
      : _apiService = ApiService(),
        _storage = const FlutterSecureStorage();

  // остальные методы без изменений...
  Future<UserModel> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.post('/api/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        final data = response.data;

        // Сохраняем токены
        await _storage.write(key: 'auth_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);

        // Сохраняем данные пользователя
        final user = UserModel.fromJson(data['user']);
        await _storage.write(key: 'user_data', value: json.encode(user.toJson()));

        // Логируем сохранение токена
        final savedToken = await _storage.read(key: 'auth_token');
        print('✅ Token saved: ${savedToken?.substring(0, 20)}...');

        print('✅ Login successful: ${user.email}');
        return user;
      } else {
        throw Exception('Ошибка авторизации: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/api/auth/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_data');
      print('✅ Logout successful');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null) {
        return UserModel.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}