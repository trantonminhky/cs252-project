import "package:virtour_frontend/screens/data factories/filter_type.dart";
import "package:virtour_frontend/screens/data factories/place.dart";
import "package:virtour_frontend/screens/data factories/region.dart";

//this is an interface for fetching region data from database
class RegionService {
  static final RegionService _instance = RegionService._internal();
  factory RegionService() {
    return _instance;
  }
  RegionService._internal();

  Future<Region> getRegionbyId(String regionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    //test data
    return getRegionTest("sg");
  }

  //test function with mock data
  Region getRegionTest(String regionId) {
    // Mock data for demonstration - replace with real shit later
    if (regionId == "sg") {
      return const Region(
        id: "sg",
        name: "Sài Gòn",
        imageUrl: "assets/images/places/Saigon.png",
        description:
            'Saigon is the former name of Ho Chi Minh City, one of the most attractive tourist destinations in Vietnam. The name Saigon has intrigued travelers for centuries with its blend of French colonial architecture, bustling markets, and vibrant street life. This dynamic metropolis offers visitors an unforgettable experience, from historic landmarks like the Notre Dame Cathedral and Independence Palace to the authentic flavors of Vietnamese cuisine found in every corner. Whether you\'re exploring the Cu Chi Tunnels, shopping at Ben Thanh Market, or simply watching life unfold from a sidewalk café, Saigon captivates with its energy and charm.',
        placesId: [
          "cu-chi-tunnels",
          "ben-thanh-market",
          'independence_palace',
          'notre_dame_cathedral',
          'ba_thien_hau_pagoda'
        ],
      );
    } else {
      throw Exception("Region not found");
    }
  }

  List<Place> filterPlaces(List<Place> places, FilterType filterType) {
    if (filterType == FilterType.regionOverview) {
      return places; // Show all places for overview
    }
    return places.where((place) => place.type == filterType).toList();
  }

  Future<List<Place>> fetchPlaceById(String regionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for demonstration - replace with real shit later
    return getPlaceTest(regionId);
  }

  List<Place> getPlaceTest(String regionId) {
    //mock data, replace with real shit later
    return <Place>[
      Place(
          id: 'cu-chi-tunnels',
          name: 'Cu Chi Tunnels',
          categories: const ['historical', 'most-visited'],
          imageUrl: 'assets/images/places/Cu_Chi_Tunnel.jpg',
          description:
              'An immense network of underground tunnels used during the Vietnam War.',
          type: FilterType.historical,
          latitude: 192.324032,
          longitude: 594.29329,
          address: 'idk bruh'),
      Place(
          id: 'notre_dame_cathedral',
          name: 'Notre Dame Cathedral',
          categories: const ['religious', 'landmark'],
          imageUrl: 'assets/images/places/Notre_Dame_Cathedral.jpg',
          description:
              'A stunning French colonial cathedral in the heart of Saigon.',
          type: FilterType.religion,
          latitude: 10.779738,
          longitude: 106.699092,
          address: '01 Công xã Paris, Quận 1, TP. HCM'),
      Place(
          id: 'ba_thien_hau_pagoda',
          name: 'Ba Thien Hau Pagoda',
          categories: const ['religious', 'cultural'],
          imageUrl: 'assets/images/places/Ba_Thien_Hau.jpg',
          description:
              'A beautiful Chinese temple dedicated to the goddess of the sea.',
          type: FilterType.religion,
          latitude: 10.754439,
          longitude: 106.655724,
          address: '710 Nguyễn Trãi, Quận 5, TP. HCM'),
      Place(
          id: 'ben-thanh-market',
          name: 'Ben Thanh Market',
          categories: const ['shopping', 'most-visited'],
          imageUrl: 'assets/images/places/Ben_Thanh_Market.jpg',
          description:
              'A vibrant marketplace offering local food, souvenirs, and handicrafts.',
          type: FilterType.culture,
          latitude: 10.772461,
          longitude: 106.698055,
          address: 'Lê Lợi, Phường Bến Thành, Quận 1'),
      Place(
          id: 'independence_palace',
          name: 'Independence Palace',
          categories: const ['historical', 'landmark'],
          imageUrl: 'assets/images/places/Independence_Palace.jpg',
          description:
              'Historic landmark and former presidential palace of South Vietnam.',
          type: FilterType.historical,
          latitude: 10.777229,
          longitude: 106.695271,
          address: '135 Nam Kỳ Khởi Nghĩa, Quận 1'),
      Place(
          id: 'notre_dame_cathedral',
          name: 'Notre Dame Cathedral',
          categories: const ['religious', 'landmark'],
          imageUrl: 'assets/images/places/Notre_Dame_Cathedral.jpg',
          description:
              'A stunning French colonial cathedral in the heart of Saigon.',
          type: FilterType.religion,
          latitude: 10.779738,
          longitude: 106.699092,
          address: '01 Công xã Paris, Quận 1'),
    ];
  }
}
