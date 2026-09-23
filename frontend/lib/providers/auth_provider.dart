import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  bool _loading = false;
  bool _isLoggedIn = false;

  bool get loading => _loading;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> signin(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await apiService.signin(email, password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      debugPrint('SIGNIN ERROR: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> signup(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await apiService.signup(email, password);
      _isLoggedIn = true;
      return null;
    } on DioException catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (statusCode == 409) {
        return 'This email is already registered.';
      }

      if (statusCode == 400) {
        final message = responseData is Map ? responseData['message'] : null;
        if (message is String && message.isNotEmpty) {
          return message;
        }
        if (message is List && message.isNotEmpty) {
          return message.join('\n');
        }
        return 'Invalid email or password.';
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Unable to connect to the backend.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again.';
      }

      return 'Signup failed. Please try again.';
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      return 'Signup failed. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await apiService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    final token = await apiService.getToken();

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }
}
