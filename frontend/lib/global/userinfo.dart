enum UserType { business, tourist }

class UserInfo {
  final String userSessionToken;
  final String userID;
  final String username;
  final UserType userType;
  final List<String> preferences;

  static const tunnelUrl =
      "https://handling-memories-merry-coins.trycloudflare.com";
  //static const tunnelUrl = "http://localhost:3000";

  const UserInfo({
    required this.userSessionToken,
    required this.userID,
    required this.username,
    required this.userType,
    required this.preferences,
  });

  factory UserInfo.fromProfileData(
      String token, String userID, Map<String, dynamic> profileData) {
    // Safely parse preferences
    List<String> parsePreferences(dynamic prefs) {
      if (prefs == null) return [];
      if (prefs is List) {
        return prefs.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserInfo(
      userSessionToken: token,
      userID: userID,
      username: profileData["username"] ?? "",
      userType: profileData["type"] == "tourist"
          ? UserType.tourist
          : UserType.business,
      preferences: parsePreferences(profileData["preferences"]),
    );
  }

  UserInfo copyWith({
    String? userSessionToken,
    String? userID,
    String? username,
    UserType? userType,
    List<String>? preferences,
  }) {
    return UserInfo(
      userSessionToken: userSessionToken ?? this.userSessionToken,
      userID: userID ?? this.userID,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      preferences: preferences ?? this.preferences,
    );
  }
}
