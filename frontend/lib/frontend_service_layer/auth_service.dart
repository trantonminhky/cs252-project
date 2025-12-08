import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

class email {
  late final Dio _dio;
  final String _baseUrl = UserInfo().tunnelUrl;
  UserInfo userInfo = UserInfo();

  email() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));
  }

  Future<Map<String, dynamic>> signIn(
      String email, String password, bool staySignedIn) async {
    try {
      final response = await _dio.post("$_baseUrl/api/profile/login", data: {
        "email": email,
        "password": password,
        "staySignedIn": staySignedIn,
      });

      final body = response.data as Map<String, dynamic>;

      if (body['success'] == true && response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final payload = body["payload"];

        final payloadMap = payload as Map<String, dynamic>;
        final data = payloadMap["data"];

        if (data == null) {
          throw Exception('Data is null');
        }

        final dataMap = data as Map<String, dynamic>;
        final token = dataMap["token"]?.toString() ?? '';

        if (token.isEmpty) {
          throw Exception('Token is empty');
        }

        await prefs.setString("token", token);
        await prefs.setString("email", email);

        // Set token in UserInfo before calling getUserInfo
        UserInfo().accessToken = token;

        // Call getUserInfo to populate all user data
        await UserInfo().getUserInfo(dataMap);

        return response.data;
      } else {
        final success = body["success"] as bool;
        final payload = body["payload"] as Map<String, dynamic>;
        final message = payload["message"] as String;
        return {'success': success, 'message': message};
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUp(
      String email,
      String password,
      String name,
      String username,
      int age,
      bool isTourist,
      List<String> preferences,
      bool staySignedIn) async {
    try {
      final response = await _dio.post("$_baseUrl/api/profile/register", data: {
        "email": email,
        "password": password,
        "name": name,
        "username": username,
        "age": age,
        "type": isTourist ? "tourist" : "business",
        "preferences": preferences,
        "staySignedIn": staySignedIn,
      });
      print(response.data["payload"]["message"]);
      final prefs = await SharedPreferences.getInstance();
      final body = response.data as Map<String, dynamic>;
      switch (response.statusCode) {
        case 200:
          final payload = body["payload"] as Map<String, dynamic>;
          final data = payload["data"] as Map<String, dynamic>;
          final token = data["token"] as String;
          await prefs.setString("token", token);
          return response.data;
        default:
          final success = body["success"] as bool;
          final payload = body["payload"] as Map<String, dynamic>;
          final message = payload["message"] as String;
          return {'success': success, 'message': message};
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    }
  }

  // Restore UserInfo from SharedPreferences on app start
  Future<void> restoreUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final email = prefs.getString("email");

    if (token != null && email != null) {
      UserInfo().accessToken = token;
      UserInfo().email = email;
    }
  }
}
