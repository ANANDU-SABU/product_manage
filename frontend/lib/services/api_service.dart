import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ============================================================
  // API BASE URL
  // ============================================================
  //
  // Web:
  //   localhost points to your development computer.
  //
  // Android Emulator:
  //   10.0.2.2 points to the development computer.
  //
  // iOS Simulator:
  //   localhost points to the development computer.
  //
  // Physical device:
  //   Replace PHYSICAL_DEVICE_IP with your computer's LAN IP.
  //
  // Example:
  //   http://192.168.1.100:3000/api
  //
  // ============================================================

  static const String physicalDeviceIp = '192.168.1.100';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android Emulator
        return 'http://10.0.2.2:3000/api';

      case TargetPlatform.iOS:
        // iOS Simulator
        return 'http://localhost:3000/api';

      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://localhost:3000/api';

      case TargetPlatform.fuchsia:
        return 'http://localhost:3000/api';
    }
  }

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String tokenKey = 'token';
  static const String userEmailKey = 'userEmail';

  // ============================================================
  // DIO
  // ============================================================

  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },

        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),

        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    // ==========================================================
    // REQUEST / RESPONSE INTERCEPTOR
    // ==========================================================

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint(
            'API REQUEST: ${options.method} ${options.uri}',
          );

          if (options.data != null) {
            debugPrint(
              'API REQUEST DATA: ${options.data}',
            );
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint(
            'API RESPONSE: '
            '${response.statusCode} ${response.requestOptions.uri}',
          );

          debugPrint(
            'API RESPONSE DATA: ${response.data}',
          );

          handler.next(response);
        },

        onError: (DioException error, handler) async {
          debugPrint(
            'API ERROR: '
            '${error.requestOptions.method} '
            '${error.requestOptions.uri}',
          );

          debugPrint(
            'STATUS: ${error.response?.statusCode}',
          );

          debugPrint(
            'RESPONSE: ${error.response?.data}',
          );

          debugPrint(
            'MESSAGE: ${error.message}',
          );

          // Automatically remove invalid token.
          if (error.response?.statusCode == 401) {
            await logout();
          }

          handler.next(error);
        },
      ),
    );
  }

  // ============================================================
  // TOKEN STORAGE
  // ============================================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);

    debugPrint('TOKEN SAVED');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  // ============================================================
  // USER EMAIL STORAGE
  // ============================================================

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userEmailKey);
  }

  // ============================================================
  // AUTHENTICATION STATE
  // ============================================================

  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userEmailKey);

    debugPrint('USER LOGGED OUT');
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<Response> signup(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw StateError(
          'Invalid signup response from server.',
        );
      }

      // --------------------------------------------------------
      // ACCESS TOKEN
      // --------------------------------------------------------

      final accessToken = data['accessToken'];

      if (accessToken is! String || accessToken.isEmpty) {
        throw StateError(
          'Signup response did not contain an access token.',
        );
      }

      await saveToken(accessToken);

      // --------------------------------------------------------
      // USER
      // --------------------------------------------------------

      final user = data['user'];

      if (user is Map) {
        final userEmail = user['email'];

        if (userEmail is String && userEmail.isNotEmpty) {
          await saveUserEmail(userEmail);
        }
      }

      debugPrint(
        'SIGNUP SUCCESS: ${response.statusCode}',
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'SIGNUP STATUS: ${e.response?.statusCode}',
      );

      debugPrint(
        'SIGNUP RESPONSE: ${e.response?.data}',
      );

      debugPrint(
        'SIGNUP ERROR: ${e.message}',
      );

      rethrow;
    }
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<Response> signin(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw StateError(
          'Invalid signin response from server.',
        );
      }

      // --------------------------------------------------------
      // ACCESS TOKEN
      // --------------------------------------------------------

      final accessToken = data['accessToken'];

      if (accessToken is! String || accessToken.isEmpty) {
        throw StateError(
          'Signin response did not contain an access token.',
        );
      }

      await saveToken(accessToken);

      // --------------------------------------------------------
      // USER
      // --------------------------------------------------------

      final user = data['user'];

      if (user is Map) {
        final userEmail = user['email'];

        if (userEmail is String && userEmail.isNotEmpty) {
          await saveUserEmail(userEmail);
        }
      }

      debugPrint(
        'SIGNIN SUCCESS: ${response.statusCode}',
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'SIGNIN STATUS: ${e.response?.statusCode}',
      );

      debugPrint(
        'SIGNIN RESPONSE: ${e.response?.data}',
      );

      debugPrint(
        'SIGNIN ERROR: ${e.message}',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  Future<Response> getProducts() async {
    try {
      final response = await dio.get(
        '/products',
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'GET PRODUCTS ERROR: ${e.response?.data}',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET SINGLE PRODUCT
  // ============================================================

  Future<Response> getProduct(
    String id,
  ) async {
    try {
      final response = await dio.get(
        '/products/$id',
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'GET PRODUCT ERROR: ${e.response?.data}',
      );

      rethrow;
    }
  }

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

  Future<Response> createProduct({
    required String name,
    required String category,
    required int quantity,
    required double price,
  }) async {
    try {
      final response = await dio.post(
        '/products',
        data: {
          'name': name,
          'category': category,
          'quantity': quantity,
          'price': price,
        },
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'CREATE PRODUCT ERROR: ${e.response?.data}',
      );

      rethrow;
    }
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<Response> updateProduct({
    required String id,
    required String name,
    required String category,
    required int quantity,
    required double price,
  }) async {
    try {
      final response = await dio.patch(
        '/products/$id',
        data: {
          'name': name,
          'category': category,
          'quantity': quantity,
          'price': price,
        },
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'UPDATE PRODUCT ERROR: ${e.response?.data}',
      );

      rethrow;
    }
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<Response> deleteProduct(
    String id,
  ) async {
    try {
      final response = await dio.delete(
        '/products/$id',
      );

      return response;
    } on DioException catch (e) {
      debugPrint(
        'DELETE PRODUCT ERROR: ${e.response?.data}',
      );

      rethrow;
    }
  }

  // ============================================================
  // FRIENDLY ERROR MESSAGE
  // ============================================================

  String getErrorMessage(
    Object error,
  ) {
    if (error is DioException) {
      final response = error.response;

      if (response != null) {
        final data = response.data;

        if (data is Map) {
          final message = data['message'];

          if (message is String && message.isNotEmpty) {
            return message;
          }

          if (message is List && message.isNotEmpty) {
            return message.join(', ');
          }

          final errorMessage = data['error'];

          if (errorMessage is String &&
              errorMessage.isNotEmpty) {
            return errorMessage;
          }
        }

        switch (response.statusCode) {
          case 400:
            return 'Invalid request. Please check your input.';

          case 401:
            return 'Invalid email or password.';

          case 403:
            return 'You do not have permission to perform this action.';

          case 404:
            return 'The requested resource was not found.';

          case 409:
            return 'This record already exists.';

          case 500:
            return 'Server error. Please try again later.';
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out.';

        case DioExceptionType.sendTimeout:
          return 'Request timed out while sending.';

        case DioExceptionType.receiveTimeout:
          return 'Server response timed out.';

        case DioExceptionType.connectionError:
          return 'Unable to connect to the server.';

        case DioExceptionType.badCertificate:
          return 'The server certificate is invalid.';

        case DioExceptionType.cancel:
          return 'Request was cancelled.';

        default:
          return error.message ?? 'Network request failed.';
      }
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';

// class ApiService {
//   static const String baseUrl = 'http://localhost:3000/api';

//   final Dio dio = Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       headers: {'Content-Type': 'application/json'},
//     ),
//   );

//   Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   Future<void> saveUserEmail(String email) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userEmail', email);
//   }

//   Future<String?> getUserEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userEmail');
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('userEmail');
//   }

//   Future<Response> signup(String email, String password) async {
//     try {
//       final response = await dio.post(
//         '/auth/signup',
//         data: {'email': email, 'password': password},
//       );

//       final user = response.data['user'];
//       debugPrint(
//         'SIGNUP SUCCESS: status=${response.statusCode}, user=${user is Map ? user['email'] : 'unknown'}',
//       );

//       final accessToken = response.data['accessToken'];
//       if (accessToken is! String || accessToken.isEmpty) {
//         throw StateError('Signup response did not contain an access token');
//       }
//       await saveToken(accessToken);
//       if (user is Map && user['email'] is String) {
//         await saveUserEmail(user['email'] as String);
//       }

//       return response;
//     } on DioException catch (e) {
//       debugPrint('SIGNUP STATUS: ${e.response?.statusCode}');
//       debugPrint('SIGNUP RESPONSE: ${e.response?.data}');
//       debugPrint('SIGNUP ERROR: ${e.message}');
//       rethrow;
//     }
//   }

//   Future<Response> signin(String email, String password) async {
//     try {
//       final response = await dio.post(
//         '/auth/signin',
//         data: {'email': email, 'password': password},
//       );

//       await saveToken(response.data['accessToken']);
//       final user = response.data['user'];
//       if (user is Map && user['email'] is String) {
//         await saveUserEmail(user['email'] as String);
//       }

//       return response;
//     } on DioException catch (e) {
//       debugPrint('SIGNIN STATUS: ${e.response?.statusCode}');
//       debugPrint('SIGNIN RESPONSE: ${e.response?.data}');
//       debugPrint('SIGNIN ERROR: ${e.message}');
//       rethrow;
//     }
//   }

//   Future<Response> getProducts() async {
//     final token = await getToken();

//     return dio.get(
//       '/products',
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//   }

//   Future<Response> createProduct({
//     required String name,
//     required String category,
//     required int quantity,
//     required double price,
//   }) async {
//     final token = await getToken();

//     return dio.post(
//       '/products',
//       data: {
//         'name': name,
//         'category': category,
//         'quantity': quantity,
//         'price': price,
//       },
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//   }

//   Future<Response> getProduct(String id) async {
//     final token = await getToken();

//     return dio.get(
//       '/products/$id',
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//   }

//   Future<Response> updateProduct({
//     required String id,
//     required String name,
//     required String category,
//     required int quantity,
//     required double price,
//   }) async {
//     final token = await getToken();

//     return dio.patch(
//       '/products/$id',
//       data: {
//         'name': name,
//         'category': category,
//         'quantity': quantity,
//         'price': price,
//       },
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//   }

//   Future<Response> deleteProduct(String id) async {
//     final token = await getToken();

//     return dio.delete(
//       '/products/$id',
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//   }
// }
