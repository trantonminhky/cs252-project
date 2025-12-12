import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";
//import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

class AuthService {
  late final Dio _dio;
  final String _baseUrl = UserInfo.tunnelUrl;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
  }

  Future<UserInfo?> signIn(String email, String password) async {
    try {
      final loginResponse = await _dio.post(
        "$_baseUrl/api/profile/login",
        data: {"email": email, "password": password},
      );

      if (loginResponse.statusCode != 200) return null;

      final loginBody = loginResponse.data;
      if (!loginBody['success']) return null;

      final loginData = loginBody["payload"]["data"];
      final String token = loginData["token"];
      final String userID = loginData["userID"];

      final profileResponse = await _dio.get("$_baseUrl/api/profile/$userID");

      if (profileResponse.statusCode != 200) return null;

      final profileBody = profileResponse.data;
      if (!profileBody["success"]) return null;

      final profileData =
          profileBody["payload"]["data"] as Map<String, dynamic>;

      return UserInfo.fromProfileData(token, userID, profileData);
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signUp(String email, String username, String password,
      String name, int age, bool isTourist, List<String> preferences) async {
    try {
      final response = await _dio.post("$_baseUrl/api/profile/register", data: {
        "email": email,
        "username": username,
        "password": password,
        "name": name,
        "age": age,
        "type": isTourist ? "tourist" : "organizer",
        "preferences": preferences,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["success"];
      }
      return false;
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    }
  }
}
