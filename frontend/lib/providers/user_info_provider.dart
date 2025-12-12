import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/global/userinfo.dart';
import 'package:dio/dio.dart';

part 'user_info_provider.g.dart';

@Riverpod(keepAlive: true)
class UserSession extends _$UserSession {
  @override
  UserInfo? build() {
    return null;
  }

  void setUser(UserInfo user) {
    state = user;
  }

  // may be used later
  void logout() {
    state = null;
  }

  void refreshSessionToken(String newToken) {
    if (state != null) {
      state = state!.copyWith(userSessionToken: newToken);
    }
  }

  Future<void> fetchAndUpdatePreferences() async {
    if (state == null) return;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: UserInfo.tunnelUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final response = await dio.get('/api/profile/${state!.userID}');

      if (response.statusCode == 200) {
        final body = response.data;
        if (body['success'] == true) {
          final profileData = body['payload']['data'];
          final preferences = profileData['preferences'];

          List<String> prefList = [];
          if (preferences is List) {
            prefList = preferences.map((e) => e.toString()).toList();
          }

          state = state!.copyWith(preferences: prefList);
        }
      }
    } catch (e) {
      print('Error fetching preferences: $e');
    }
  }
}
