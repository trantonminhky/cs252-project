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

  String userSessionToken = 'MIKU_MIKU_OO_EE_OO';
  UserType userType = UserType.tourist;
  String username = '';
  List<String> preferences = [];
  //for the sake of convenience
  final String tunnelUrl =
      'https://chelsea-scuba-bureau-imposed.trycloudflare.com';
}
