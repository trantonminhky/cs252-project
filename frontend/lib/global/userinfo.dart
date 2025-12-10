enum UserType { business, tourist }

class UserInfo {
  final String userSessionToken;
  final String userID;
  final String username;
  final String discriminant;
  final UserType userType;
  final List<String> preferences;

  static String tunnelUrl =
      "https://gap-lodging-transparency-increase.trycloudflare.com";

  const UserInfo({
    required this.userSessionToken,
    required this.userID,
    required this.username,
    required this.discriminant,
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
      discriminant: profileData["discriminant"] ?? "",
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
    String? discriminant,
    UserType? userType,
    List<String>? preferences,
  }) {
    return UserInfo(
      userSessionToken: userSessionToken ?? this.userSessionToken,
      userID: userID ?? this.userID,
      username: username ?? this.username,
      discriminant: discriminant ?? this.discriminant,
      userType: userType ?? this.userType,
      preferences: preferences ?? this.preferences,
    );
  }
}
