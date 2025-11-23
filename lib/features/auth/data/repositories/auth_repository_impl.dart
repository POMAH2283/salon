import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/api_service.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final FlutterSecureStorage _storage;
  static const String _currentUserKey = 'current_user_data';

  // Конструктор без параметров
  AuthRepositoryImpl()
      : _storage = const FlutterSecureStorage();

  // Login method - works only with backend database
  Future<UserModel> login(String email, String password) async {
    try {
      print('🔄 Starting login for: $email');
      print('📡 Making API call to: /api/auth/login');

      // Login with backend database
      final request = LoginRequest(email: email, password: password);
      final response = await ApiService.instance.post('/api/auth/login', data: request.toJson());

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Сохраняем токены
        await _storage.write(key: 'auth_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);

        // Сохраняем данные пользователя
        final user = UserModel.fromJson(data['user']);
        await _storage.write(key: _currentUserKey, value: json.encode(user.toJson()));

        print('✅ Backend login successful: ${user.email}');
        return user;
      } else {
        throw Exception('Ошибка авторизации: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Backend login failed: $e');
      throw Exception('Ошибка авторизации: $e');
    }
  }

  // Registration method - saves to server database
  Future<UserModel> register(String name, String email, String password) async {
    try {
      print('🔄 Starting registration for: $email');
      print('📡 Making API call to: /api/auth/register');

      // Call backend API to register user in PostgreSQL database
      final response = await ApiService.instance.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;

        // Save tokens to local storage
        await _storage.write(key: 'auth_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);

        // Create UserModel from response data
        final user = UserModel.fromJson(data['user']);
        await _storage.write(key: _currentUserKey, value: json.encode(user.toJson()));

        print('✅ Server registration successful: ${user.email}');
        print('✅ User saved to PostgreSQL database');
        return user;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Registration error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      // Parse error message from backend
      if (e.toString().contains('409') || e.toString().contains('already exists')) {
        throw Exception('Пользователь с таким email уже существует');
      }
      
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Backend logout
      await ApiService.instance.post('/api/auth/logout', data: {});
      print('✅ Backend logout successful');
    } catch (e) {
      print('Backend logout error: $e (ignoring)');
    } finally {
      // Clear local storage (tokens and current user only)
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: _currentUserKey);
      print('✅ Logout successful - tokens cleared');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _currentUserKey);
      if (userData != null) {
        return UserModel.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

}
