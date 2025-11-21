import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Для Android эмулятора:
  static const String baseUrl = 'https://autosalon-backend.onrender.com';
  // Для браузера: static const String baseUrl = 'http://localhost:3000';

  // Конструктор без параметров
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔑 Token attached to request: ${token.substring(0, 20)}...');
    } else {
      print('❌ No token found for request');
    }

    options.headers['Content-Type'] = 'application/json';
    print('🚀 API Request: ${options.method} ${options.path}');
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    print('❌ API Error: ${error.message}');
    print('❌ Status Code: ${error.response?.statusCode}');
    print('❌ Response Data: ${error.response?.data}');

    // Если 403 - возможно токен истек
    if (error.response?.statusCode == 403) {
      print('🔐 403 Forbidden - возможно токен истек или невалиден');
      final currentToken = await _storage.read(key: 'auth_token');
      print('🔐 Current token: ${currentToken?.substring(0, 20)}...');
    }

    handler.next(error);
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }
}