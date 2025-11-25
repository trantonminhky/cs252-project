import "package:virtour_frontend/screens/data factories/filter_type.dart";
import "package:virtour_frontend/screens/data factories/place.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

class PlaceService {
  //dio brando lol
  late final Dio dio;
  //just singleton pattern
  static final PlaceService _instance = PlaceService._internal();
  factory PlaceService() {
    return _instance;
  }
  PlaceService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'placeholder/url',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    List<Place> filterPlaces(List<Place> places, FilterType filterType) {
      if (filterType == FilterType.regionOverview) {
        return places; // Show all places for overview
      }
      return places.where((place) => place.type == filterType).toList();
    }

    Future<Place> fetchPlaceById(String placeId) async {
      final response = await dio.get('/places/$placeId');
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

          return Place.fromBson(payload);
      }
    }

    // List<Place> getPlaceTest(String regionId) {
    //   //mock data, replace with real shit later
    //   return <Place>[
    //     Place(
    //         id: 'cu-chi-tunnels',
    //         name: 'Cu Chi Tunnels',
    //         categories: const ['historical', 'most-visited'],
    //         imageUrl: 'assets/images/places/Cu_Chi_Tunnel.jpg',
    //         description:
    //             'An immense network of underground tunnels used during the Vietnam War.',
    //         type: FilterType.historical,
    //         latitude: 192.324032,
    //         longitude: 594.29329,
    //         address: 'idk bruh'),
    //     Place(
    //         id: 'notre_dame_cathedral',
    //         name: 'Notre Dame Cathedral',
    //         categories: const ['religious', 'landmark'],
    //         imageUrl: 'assets/images/places/Notre_Dame_Cathedral.jpg',
    //         description:
    //             'A stunning French colonial cathedral in the heart of Saigon.',
    //         type: FilterType.religion,
    //         latitude: 10.779738,
    //         longitude: 106.699092,
    //         address: '01 Công xã Paris, Quận 1, TP. HCM'),
    //     Place(
    //         id: 'ba_thien_hau_pagoda',
    //         name: 'Ba Thien Hau Pagoda',
    //         categories: const ['religious', 'cultural'],
    //         imageUrl: 'assets/images/places/Ba_Thien_Hau.jpg',
    //         description:
    //             'A beautiful Chinese temple dedicated to the goddess of the sea.',
    //         type: FilterType.religion,
    //         latitude: 10.754439,
    //         longitude: 106.655724,
    //         address: '710 Nguyễn Trãi, Quận 5, TP. HCM'),
    //     Place(
    //         id: 'ben-thanh-market',
    //         name: 'Ben Thanh Market',
    //         categories: const ['shopping', 'most-visited'],
    //         imageUrl: 'assets/images/places/Ben_Thanh_Market.jpg',
    //         description:
    //             'A vibrant marketplace offering local food, souvenirs, and handicrafts.',
    //         type: FilterType.culture,
    //         latitude: 10.772461,
    //         longitude: 106.698055,
    //         address: 'Lê Lợi, Phường Bến Thành, Quận 1'),
    //     Place(
    //         id: 'independence_palace',
    //         name: 'Independence Palace',
    //         categories: const ['historical', 'landmark'],
    //         imageUrl: 'assets/images/places/Independence_Palace.jpg',
    //         description:
    //             'Historic landmark and former presidential palace of South Vietnam.',
    //         type: FilterType.historical,
    //         latitude: 10.777229,
    //         longitude: 106.695271,
    //         address: '135 Nam Kỳ Khởi Nghĩa, Quận 1'),
    //     Place(
    //         id: 'notre_dame_cathedral',
    //         name: 'Notre Dame Cathedral',
    //         categories: const ['religious', 'landmark'],
    //         imageUrl: 'assets/images/places/Notre_Dame_Cathedral.jpg',
    //         description:
    //             'A stunning French colonial cathedral in the heart of Saigon.',
    //         type: FilterType.religion,
    //         latitude: 10.779738,
    //         longitude: 106.699092,
    //         address: '01 Công xã Paris, Quận 1'),
    //   ];
    // }
  }
}
