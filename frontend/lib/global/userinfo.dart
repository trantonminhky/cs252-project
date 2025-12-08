import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

enum UserType { business, tourist }

class UserInfo {
  UserInfo._internal() {
    _loadTunnelUrl();
  }
  static final UserInfo _instance = UserInfo._internal();
  factory UserInfo() => _instance;

  Future<void> _loadTunnelUrl() async {
    try {
      final String response = await rootBundle.loadString('assets/helper.json');
      final data = json.decode(response);
      tunnelUrl = data['tunnel'];
    } catch (e) {
      print('Error loading tunnel URL: $e');
    }
  }

  static void init({
    required String token,
    required String userId,
    UserType type = UserType.tourist,
    required List<String> preferences,
  }) {
    _instance.accessToken = token;
    _instance.userId = userId;
    _instance.userType = type;
    _instance.preferences = preferences;
  }

  static void dispose() {
    _instance.accessToken = '';
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
  String accessToken = 'MIKU_MIKU_OO_EE_OO';
  //use the user id to get info about user through "/api/profile/${userId}"
  String userId = '';
  //use the user id to get username
  String email = 'guest';
  String username = 'anon';
  String name = 'anon';
  int age = 0;
  List<String> savedPlaces = [];

  //for the sake of convenience
  String tunnelUrl = '';

  Future<void> getUserInfo(final body) async {
    try {
      // Initialize email
      email = body['email'] as String? ?? 'guest';

      // Initialize username
      username = body['username'] as String? ?? 'guest';

      // Initialize name
      name = body['name'] as String? ?? '';

      // Initialize age
      age = body['age'] as int? ?? 0;

      // Initialize user id
      userId = body['userID'] as String? ?? '';

      // Initialize user type
      final typeStr = body['type'] as String? ?? 'tourist';
      userType = (typeStr == 'tourist') ? UserType.tourist : UserType.business;

      // Initialize token
      accessToken = body['token'] as String? ?? '';

      // Initialize staySignedIn
      staySignedIn = body['staySignedIn'] as bool? ?? false;

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
    } catch (e) {
      // Handle errors and set defaults
      email = 'guest';
      name = '';
      age = 0;
      preferences = [];
      savedPlaces = [];
      print('Error fetching user info: $e');
    }
  }
}
