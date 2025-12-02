import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/constants/userinfo.dart";

//this is an interface for fetching region data from database
class RegionService {
  static final RegionService _instance = RegionService._internal();
  late final Dio dio;
  static const String _baseUrl =
      "https://chelsea-scuba-bureau-imposed.trycloudflare.com/api";
  late final UserInfo userInfo;

  factory RegionService() {
    return _instance;
  }
  RegionService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
    userInfo = UserInfo();

    // Add interceptor for authentication
    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       if (userInfo.userSessionToken.isNotEmpty) {
    //         options.headers["Authorization"] =
    //             "Bearer ${userInfo.userSessionToken}";
    //       }
    //       return handler.next(options);
    //     },
    //     onError: (DioException e, handler) {
    //       print('ERROR[${e.response?.statusCode}] => MESSAGE: ${e.message}');
    //       return handler.next(e);
    //     },
    //   ),
    // );
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
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load region: $e');
    }
  }

  Future<Place> fetchPlacebyId(String placeId) async {
    try {
      final response = await dio.get('/places/$placeId');

      switch (response.statusCode) {
        case 200:
          final data = response.data;
          if (data['success']) {
            final placeData = data['data'] ?? data['payload']?['data'];

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
      throw _handleDioError(e);
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

  Future<List<Place>> getFilteredPlaces(
      String query, List<String> includeFilter) async {
    try {
      final response = await dio.get('$_baseUrl/location/search', data: {
        'query': query,
        'include': includeFilter.join(','),
      });
      final body = response.data as Map<String, dynamic>;
      switch (response.statusCode) {
        case 200:
          final placesData = body["payload"]["data"] as List<dynamic>;
          return placesData.map<Place>((json) => Place.fromJson(json)).toList();
        default:
          final message = body["payload"]["message"] as String;
          throw Exception('Failed to load filtered places: $message');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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

  Exception _handleDioError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        switch (statusCode) {
          case 400:
            errorMessage = data?['error']?['message'] ?? 'Bad request';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 404:
            errorMessage = data?['error']?['message'] ?? 'Resource not found';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage =
                data?['error']?['message'] ?? 'Server error occurred';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection failed. Please check your internet.';
        break;
      default:
        errorMessage = 'Network error. Please check your connection.';
    }

    return Exception(errorMessage);
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
}
