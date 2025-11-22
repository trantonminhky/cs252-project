import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthService {
  late final Dio _dio;
  static const String _baseUrl = "https://localhost:3000/api";
  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("auth_token");
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> signIn(String username, String password) async {
    try {
      final response = await _dio.post("/auth/signin", data: {
        "username": username,
        "password": password,
      });
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", response.data["token"]);
        return response.data;
      } else {
        throw Exception("Failed to sign in: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUp(String username, String password) async {
    try {
      final response = await _dio.post("/auth/signup", data: {
        "username": username,
        "password": password,
      });
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", response.data["token"]);
        return response.data;
      } else {
        throw Exception("Failed to sign up: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
