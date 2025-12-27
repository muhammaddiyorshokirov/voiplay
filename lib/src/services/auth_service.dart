import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final _storage = const FlutterSecureStorage();
  final _dio = ApiClient().dio;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  AuthService._internal();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    // set header for future requests
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await saveToken(token);
      }
      // store user data in secure storage if desired
      if (data.containsKey('user')) {
        await _storage.write(key: _keyUser, value: jsonEncode(data['user']));
      }
      return data;
    }

    throw Exception('Login failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await saveToken(token);
      }
      return data;
    }

    throw Exception('Register failed: ${response.statusCode}');
  }

  Future<bool> tryAutoLogin() async {
    final token = await getToken();
    if (token == null) return false;
    // Set header and optionally validate token via /users/{id} or /auth/me endpoint
    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      // Try a lightweight authenticated request to confirm token works
      final resp = await _dio.get('/users/me');
      if (resp.statusCode == 200) return true;
    } catch (_) {
      await clearToken();
      return false;
    }
    return false;
  }
}
