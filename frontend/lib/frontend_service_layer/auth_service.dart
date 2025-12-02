import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

class AuthService {
  late final Dio _dio;
  final String _baseUrl = UserInfo().tunnelUrl;
  UserInfo userInfo = UserInfo();

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
    try {
      final response = await _dio.post("$_baseUrl/api/profile/login",
          data: {"username": username, "password": password});
      final body = response.data as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
          final prefs = await SharedPreferences.getInstance();
          final payload = body["payload"] as Map<String, dynamic>;
          final data = payload["data"] as Map<String, dynamic>;
          final token = data["token"] as String;
          await prefs.setString("auth_token", token);
          UserInfo().userType =
              data["isTourist"] ? UserType.tourist : UserType.business;
          UserInfo().preferences = List<String>.from(data["preferences"] ?? []);
          return response.data;
        default:
          final success = body["success"] as bool;
          final payload = body["payload"] as Map<String, dynamic>;
          final message = payload["message"] as String;
          return {'success': success, 'message': message};
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> signUp(String username, String password,
      String name, int age, bool isTourist, List<String> preferences) async {
    try {
      final response = await _dio.post("$_baseUrl/api/profile/register", data: {
        "username": username,
        "password": password,
        "name": name,
        "age": age,
        "isTourist": isTourist,
        "preferences": preferences,
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
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    }
  }
}
