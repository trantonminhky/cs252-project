import 'package:dio/dio.dart';

enum UserType { business, tourist }

class UserInfo {
  UserInfo._internal();
  static final UserInfo _instance = UserInfo._internal();
  factory UserInfo() => _instance;
  static void init({
    required String token,
    required String userId,
    UserType type = UserType.tourist,
    required List<String> preferences,
  }) {
    _instance.userSessionToken = token;
    _instance.userId = userId;
    _instance.userType = type;
    _instance.preferences = preferences;
  }

  static void dispose() {
    _instance.userSessionToken = '';
    _instance.userId = '';
    _instance.userType = UserType.tourist;
    _instance.preferences = [];
    _instance.staySignedIn = false;
  }

  //sign up information
  UserType userType = UserType.tourist;
  List<String> preferences = [];
  bool staySignedIn = false;

  //use token to call geocode; if timeout call "api/profile/refresh" to get new token
  String userSessionToken = 'MIKU_MIKU_OO_EE_OO';
  //use the user id to get info about user through "/api/profile/${userId}"
  String userId = '';
  //use the user id to get username
  String username = 'guest';
  String name = '';
  int age = 0;
  List<String> savedPlaces = [];

  //for the sake of convenience
  final String tunnelUrl =
      'https://hospital-furnished-confidence-hunter.trycloudflare.com';

  Future<void> getUserInfo() async {
    try {
      final profile = await Dio().get(
        '$tunnelUrl/api/profile/:$userId',
      );
      final body = profile.data as Map<String, dynamic>;

      if (profile.statusCode == 200) {
        // Initialize username
        username = body['username'] as String? ?? 'guest';

        // Initialize name
        name = body['name'] as String? ?? '';

        // Initialize age
        age = body['age'] as int? ?? 0;

        // Initialize preferences
        final prefsData = body['preferences'];
        if (prefsData is List) {
          preferences = prefsData.map((e) => e.toString()).toList();
        } else if (prefsData is Map) {
          preferences = prefsData.values.map((e) => e.toString()).toList();
        } else {
          preferences = [];
        }

        // Initialize savedPlaces
        final savedData = body['savedPlaces'];
        if (savedData is List) {
          savedPlaces = savedData.map((e) => e.toString()).toList();
        } else {
          savedPlaces = [];
        }
      } else {
        // Set defaults if request failed
        username = 'guest';
        name = '';
        age = 0;
        preferences = [];
        savedPlaces = [];
      }
    } catch (e) {
      // Handle errors and set defaults
      username = 'guest';
      name = '';
      age = 0;
      preferences = [];
      savedPlaces = [];
      print('Error fetching user info: $e');
    }
  }

}
