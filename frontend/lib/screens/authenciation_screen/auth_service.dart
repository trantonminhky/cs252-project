import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthService {
  late final Dio _dio;
  static const String _baseUrl =
      "https://jackets-myth-correctly-passes.trycloudflare.com";
  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));
    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     final prefs = await SharedPreferences.getInstance();
    //     final token = prefs.getString("auth_token");
    //     if (token != null) {
    //       options.headers["Authorization"] = "Bearer $token";
    //     }
    //     return handler.next(options);
    //   },
    // ));
  }

  Future<Map<String, dynamic>> signIn(String username, String password) async {
    final response = await _dio.get(
        "$_baseUrl/api/profile/login?username=$username&password=$password");
    final body = response.data as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
        final prefs = await SharedPreferences.getInstance();
        final payload = body["payload"] as Map<String, dynamic>;
        final data = payload["data"] as Map<String, dynamic>;
        final token = data["token"] as String;
        await prefs.setString("auth_token", token);
        return response.data;
      default:
        final success = body["success"] as bool;
        final payload = body["payload"] as Map<String, dynamic>;
        final message = payload["message"] as String;
        return {'success': success, 'message': message};
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
    final prefs = await SharedPreferences.getInstance();
    final body = response.data as Map<String, dynamic>;
    switch (response.statusCode) {
      case 200:
        final payload = body["payload"] as Map<String, dynamic>;
        final data = payload["data"] as Map<String, dynamic>;
        final token = data["token"] as String;
        await prefs.setString("auth_token", token);
        return response.data;
      default:
        final success = body["success"] as bool;
        final payload = body["payload"] as Map<String, dynamic>;
        final message = payload["message"] as String;
        return {'success': success, 'message': message};
    }
  }
}
