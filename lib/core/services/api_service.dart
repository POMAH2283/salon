import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  // Для сервера:
  static const String baseUrl = 'https://autosalon1.onrender.com';
  // Для локальной разработки:
  // static const String baseUrl = 'http://localhost:3000';

  // Конструктор без параметров
  void _init() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    };

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

  Future<Response> get(String endpoint) async {
    try {
      _init();
      return await _dio.get(endpoint);
    } catch (e) {
      throw Exception('GET error: $e');
    }
  }

  Future<Response> post(String endpoint, {required dynamic data}) async {
    try {
      _init();
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw Exception('POST error: $e');
    }
  }

  Future<Response> put(String endpoint, {required dynamic data}) async {
    try {
      _init();
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw Exception('PUT error: $e');
    }
  }

  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      _init();
      if (data != null) {
        return await _dio.delete(endpoint, data: data);
      } else {
        return await _dio.delete(endpoint);
      }
    } catch (e) {
      throw Exception('DELETE error: $e');
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      _init();
      return await _dio.patch(path, data: data);
    } catch (e) {
      throw Exception('PATCH error: $e');
    }
  }

  static void init() {
    // Static method to initialize the singleton if needed
    _instance._init();
  }
}
