import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

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
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
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
                userInfo.accessToken = data['token'];
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
      },
    );
  }

  Future<Place> fetchPlacebyId(String placeId) async {
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
        final response = await dio.get('/location/search', queryParameters: {
          'userID': userInfo.userId,
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
                userInfo.accessToken = data['token'];
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
      },
    );
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
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
        final data = {
          'userID': userInfo.userId,
          'query': query,
          'include': includeFilter.join(','),
        };
        final response = await dio.post(
          '/location/search',
          data: data,
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
      },
    );
  }

  Future<List<Review>> getReviewsForPlace(String placeId) async {
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
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
                userInfo.accessToken = data['token'];
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
      },
    );
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

  // Event subscription
  Future<bool> subscribeToEvent(String username, String eventId) async {
    try {
      final response = await dio.post('/event/subscribe', data: {
        'username': username,
        'eventID': eventId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['success'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      print('Error subscribing to event: ${e.message}');
      return false;
    }
  }

  Future<bool> unsubscribeFromEvent(String username, String eventId) async {
    try {
      final response = await dio.post('/event/unsubscribe', data: {
        'username': username,
        'eventID': eventId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['success'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      print('Error unsubscribing from event: ${e.message}');
      return false;
    }
  }

  // Fetch events from database
  Future<Map<String, dynamic>> fetchEvents() async {
    try {
      final response = await dio.get('/db/export', queryParameters: {
        'name': 'EventDB',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['payload']['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } on DioException catch (e) {
      print('Error fetching events: ${e.message}');
      return {};
    }
  }

  // Fetch subscribed events for a user
  Future<List<Map<String, dynamic>>> fetchSubscribedEvents(
      String username) async {
    try {
      final response =
          await dio.get('/event/get-by-username', queryParameters: {
        'username': username,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['payload']['data']);
        }
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching subscribed events: ${e.message}');
      return [];
    }
  }

  // Fetch ML-based recommendations for a user
  Future<List<String>> fetchRecommendations(
      String userId, double lat, double lon) async {
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
        final response = await dio.get('/recommendation', queryParameters: {
          'userID': userId,
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
      },
    );
  }

  // Create a new event
  Future<Map<String, dynamic>?> createEvent({
    required String name,
    required String description,
    String? imageLink,
    int? startTime,
    int? endTime,
  }) async {
    try {
      final response = await dio.post('/event/create', data: {
        'name': name,
        'description': description,
        'imageLink': imageLink,
        'startTime': startTime,
        'endTime': endTime,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return data['payload']['data'];
        }
      }
      return null;
    } on DioException catch (e) {
      print('Error creating event: ${e.message}');
      return null;
    }
  }
}
