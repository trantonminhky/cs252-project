import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthService {
  late final Dio _dio;
  static const String _baseUrl =
      "https://jackets-myth-correctly-passes.trycloudflare.com/";
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
    final response = await _dio.get(
        "$_baseUrl/api/profile/login?username=$username&password=$password");
    switch (response.statusCode) {
      case 200:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", response.data["token"]);
        return response.data;
      case 400:
        return {
          'success': false,
          'message': response.data["message"] ?? "Bad Request"
        };
      case 401:
        return {
          'success': false,
          'message': response.data["message"] ?? "Unauthorized"
        };
      case 403:
        return {
          'success': false,
          'message': response.data["message"] ?? "Forbidden"
        };
      case 500:
        return {
          'success': false,
          'message': response.data["message"] ?? "Internal Server Error"
        };
      default:
        return {
          'success': false,
          'message': 'Unexpected error: ${response.statusCode}'
        };
    }
  }

  Future<Map<String, dynamic>> signUp(
      String username, String password, String name, int age) async {
    final response = await _dio.post("$_baseUrl/api/profile/register", data: {
      "username": username,
      "password": password,
      "name": name,
      "age": age,
    });
    switch (response.statusCode) {
      case 201:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", response.data["token"]);
        return response.data;
      case 400:
        return {
          'success': false,
          'message': response.data["message"] ?? "Bad Request"
        };
      case 401:
        return {
          'success': false,
          'message': response.data["message"] ?? "Unauthorized"
        };
      case 403:
        return {
          'success': false,
          'message': response.data["message"] ?? "Forbidden"
        };
      case 500:
        return {
          'success': false,
          'message': response.data["message"] ?? "Internal Server Error"
        };
      default:
        return {
          'success': false,
          'message': 'Unexpected error: ${response.statusCode}'
        };
    }
  }
}
