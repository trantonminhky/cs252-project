import "package:virtour_frontend/screens/data factories/region.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

//this is an interface for fetching region data from database
class RegionService {
  //dio brando lol
  late final Dio dio;

  //just singleton pattern
  static final RegionService _instance = RegionService._internal();
  factory RegionService() {
    return _instance;
  }
  RegionService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'placeholder/url',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<Region> getRegionbyId(String regionId) async {
    //mock url - need to discuss with db dudes
    final response = await dio.get('/regions/$regionId');
    final body = response.data as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
        final prefs = await SharedPreferences.getInstance();
        final payload = body["payload"] as Map<String, dynamic>;
        final data = payload["data"] as Map<String, dynamic>;
        final token = data["token"] as String;
        await prefs.setString("auth_token", token);
        return response.data;
      default:
        final success = body["success"] as bool;
        final payload = body["payload"] as Map<String, dynamic>;
        final message = payload["message"] as String;

        return Region.fromBson(payload);
    }
  }

  // //test function with mock data
  // Region getRegionTest(String regionId) {
  //   // Mock data for demonstration - replace with real shit later
  //   if (regionId == "sg") {
  //     return const Region(
  //       id: "sg",
  //       name: "Sài Gòn",
  //       imageUrl: "assets/images/places/Saigon.png",
  //       description:
  //           'Saigon is the former name of Ho Chi Minh City, one of the most attractive tourist destinations in Vietnam. The name Saigon has intrigued travelers for centuries with its blend of French colonial architecture, bustling markets, and vibrant street life. This dynamic metropolis offers visitors an unforgettable experience, from historic landmarks like the Notre Dame Cathedral and Independence Palace to the authentic flavors of Vietnamese cuisine found in every corner. Whether you\'re exploring the Cu Chi Tunnels, shopping at Ben Thanh Market, or simply watching life unfold from a sidewalk café, Saigon captivates with its energy and charm.',
  //       placesId: [
  //         "cu-chi-tunnels",
  //         "ben-thanh-market",
  //         'independence_palace',
  //         'notre_dame_cathedral',
  //         'ba_thien_hau_pagoda'
  //       ],
  //     );
  //   } else {
  //     throw Exception("Region not found");
  //   }
  // }
}
