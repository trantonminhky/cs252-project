import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

//this is an interface for fetching region data from database
class RegionService {
  static final RegionService _instance = RegionService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo().tunnelUrl;
  late final UserInfo userInfo;

  factory RegionService() {
    return _instance;
  }
  RegionService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          'Cache-Control': 'no-cache',
        },
      ),
    );
    userInfo = UserInfo();
  }

  /* 
  need functions to:
  1. fetch region by id (for now only id is 'sg')
  2. fetch place by id (place will be numbered with an id)
  */
  Future<Region> getRegionbyId(String regionId) async {
    try {
      final response = await dio.get('/regions/$regionId');

      switch (response.statusCode) {
        case 200:
          final data = response.data;
          if (data['success']) {
            final regionData = data['data'] ?? data['payload']?['data'];

            // Update token if provided
            if (data['token'] != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("auth_token", data['token']);
              userInfo.userSessionToken = data['token'];
            }

            return Region.fromJson(regionData);
          } else {
            throw Exception(data['message'] ?? 'Failed to load region');
          }
        case 404:
          throw Exception('Region not found');
        default:
          throw Exception('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load region: $e');
    }
  }

  Future<Place> fetchPlacebyId(String placeId) async {
    try {
      final response = await dio.get('/location/find-by-id', queryParameters: {
        'id': placeId,
      });

      switch (response.statusCode) {
        case 200:
          final data = response.data;
          if (data['success']) {
            final placeData = data['payload']['data'];

            // Update token if provided
            if (data['token'] != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("auth_token", data['token']);
              userInfo.userSessionToken = data['token'];
            }

            return Place.fromJson(placeData);
          } else {
            throw Exception(data['message'] ?? 'Failed to load place');
          }
        case 404:
          throw Exception('Place not found');
        default:
          throw Exception('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load place: $e');
    }
  }

  //legacy function; kept in case we need to use it
  Future<List<Place>> getAllPlaces(List<String> placesId) async {
    List<Place> places = [];
    for (String placeId in placesId) {
      try {
        Place place = await fetchPlacebyId(placeId);
        places.add(place);
      } catch (e) {
        print('Error fetching place $placeId: $e');
      }
    }
    return places;
  }

  Future<List<Place>> getPlace(String query, List<String> includeFilter) async {
    try {
      final queryParams = {
        'query': query,
        'include': includeFilter.join(','),
      };
      final response = await dio.get(
        '/location/search',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );
      final body = response.data as Map<String, dynamic>;
      switch (response.statusCode) {
        case 200:
          // Extract the locations array from payload.data
          final locations = body['payload']?['data'] as List? ?? [];
          final placesList = locations
              .map((location) => Place.fromJson(
                  Map<String, dynamic>.from(location['value'] as Map)))
              .toList();
          return placesList;
        default:
          final message = body["payload"]["message"] as String;
          throw Exception('Failed to load filtered places: $message');
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load filtered places: $e');
    }
  }

  Future<List<Review>> getReviewsForPlace(String placeId) async {
    try {
      final response = await dio.get('/places/reviews/$placeId');

      switch (response.statusCode) {
        case 200:
          final data = response.data;
          if (data['success']) {
            final reviewsData = data['reviews'] ?? [];

            // Update token if provided
            if (data['token'] != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("auth_token", data['token']);
              userInfo.userSessionToken = data['token'];
            }

            return reviewsData
                .map<Review>((json) => Review.fromJson(json))
                .toList();
          } else {
            throw Exception(data['message'] ?? 'Failed to load reviews');
          }
        case 404:
          throw Exception('Reviews not found');
        default:
          throw Exception('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Saved Places Methods
  Future<List<String>> getSavedPlaces(String username) async {
    try {
      final response = await dio.get('/profile/saved-places', queryParameters: {
        'username': username,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          final places = data['data'] ?? data['payload']?['data'] ?? [];
          return List<String>.from(places);
        }
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching saved places: ${e.message}');
      return [];
    }
  }

  Future<bool> addSavedPlace(String username, String placeId) async {
    try {
      final response = await dio.post('/profile/saved-places', data: {
        'username': username,
        'placeId': placeId,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      print('Error adding saved place: ${e.message}');
      if (e.response?.statusCode == 409) {
        // Place already saved
        return true;
      }
      return false;
    }
  }

  Future<bool> removeSavedPlace(String username, String placeId) async {
    try {
      final response = await dio.delete('/profile/saved-places', data: {
        'username': username,
        'placeId': placeId,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      print('Error removing saved place: ${e.message}');
      return false;
    }
  }

  // Fetch ML-based recommendations for a user
  Future<List<String>> fetchRecommendations(
      String username, double lat, double lon) async {
    try {
      final response = await dio.get('/recommendation', queryParameters: {
        'username': username,
        'lat': lat,
        'lon': lon,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final recommendations = data['payload']['data']['recommendations'];
          if (recommendations is List) {
            // Extract the 'id' field from each recommendation object
            return recommendations
                .map((item) => item['id'].toString())
                .toList();
          }
        }
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching recommendations: ${e.message}');
      return [];
    }
  }

  // // Create a new event
  // Future<Map<String, dynamic>?> createEvent({
  //   required String name,
  //   required String description,
  //   String? imageLink,
  //   int? startTime,
  //   int? endTime,
  // }) async {
  //   try {
  //     final response = await dio.post('/event/create', data: {
  //       'name': name,
  //       'description': description,
  //       'imageLink': imageLink,
  //       'startTime': startTime,
  //       'endTime': endTime,
  //     });

  //     if (response.statusCode == 201) {
  //       final data = response.data;
  //       if (data['success'] == true) {
  //         return data['payload']['data'];
  //       }
  //     }
  //     return null;
  //   } on DioException catch (e) {
  //     print('Error creating event: ${e.message}');
  //     return null;
  //   }
  // }
}
