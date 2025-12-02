enum UserType { business, tourist }

class UserInfo {
  UserInfo._internal();
  static final UserInfo _instance = UserInfo._internal();
  factory UserInfo() => _instance;
  static void init({
    required String token,
    required String username,
    UserType type = UserType.tourist,
    required List<String> preferences,
  }) {
    _instance.userSessionToken = token;
    _instance.username = username;
    _instance.userType = type;
    _instance.preferences = preferences;
  }

  String userSessionToken = "";
  String username = "";
  UserType userType = UserType.tourist;
  List<String> preferences = [];
}
