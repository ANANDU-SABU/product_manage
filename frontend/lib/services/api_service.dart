import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userEmail');
  }

  Future<Response> signup(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/signup',
        data: {'email': email, 'password': password},
      );

      final user = response.data['user'];
      debugPrint(
        'SIGNUP SUCCESS: status=${response.statusCode}, user=${user is Map ? user['email'] : 'unknown'}',
      );

      final accessToken = response.data['accessToken'];
      if (accessToken is! String || accessToken.isEmpty) {
        throw StateError('Signup response did not contain an access token');
      }
      await saveToken(accessToken);
      if (user is Map && user['email'] is String) {
        await saveUserEmail(user['email'] as String);
      }

      return response;
    } on DioException catch (e) {
      debugPrint('SIGNUP STATUS: ${e.response?.statusCode}');
      debugPrint('SIGNUP RESPONSE: ${e.response?.data}');
      debugPrint('SIGNUP ERROR: ${e.message}');
      rethrow;
    }
  }

  Future<Response> signin(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/signin',
        data: {'email': email, 'password': password},
      );

      await saveToken(response.data['accessToken']);
      final user = response.data['user'];
      if (user is Map && user['email'] is String) {
        await saveUserEmail(user['email'] as String);
      }

      return response;
    } on DioException catch (e) {
      debugPrint('SIGNIN STATUS: ${e.response?.statusCode}');
      debugPrint('SIGNIN RESPONSE: ${e.response?.data}');
      debugPrint('SIGNIN ERROR: ${e.message}');
      rethrow;
    }
  }

  Future<Response> getProducts() async {
    final token = await getToken();

    return dio.get(
      '/products',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> createProduct({
    required String name,
    required String category,
    required int quantity,
    required double price,
  }) async {
    final token = await getToken();

    return dio.post(
      '/products',
      data: {
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> getProduct(String id) async {
    final token = await getToken();

    return dio.get(
      '/products/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> updateProduct({
    required String id,
    required String name,
    required String category,
    required int quantity,
    required double price,
  }) async {
    final token = await getToken();

    return dio.patch(
      '/products/$id',
      data: {
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> deleteProduct(String id) async {
    final token = await getToken();

    return dio.delete(
      '/products/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
