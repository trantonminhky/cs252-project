enum UserType { business, tourist }

class UserInfo {
  UserInfo._internal();
  static final UserInfo _instance = UserInfo._internal();
  factory UserInfo() => _instance;
  static void init({required String token, UserType type = UserType.tourist}) {
    _instance.userSessionToken = token;
    _instance.userType = type;
  }

  String userSessionToken = "";
  UserType userType = UserType.tourist;
}
