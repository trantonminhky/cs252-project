import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/global/userinfo.dart';

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
}
