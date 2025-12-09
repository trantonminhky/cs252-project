import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

//this is an interface for fetching region data from database
class RegionService {
  static final RegionService _instance = RegionService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;

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
  }

  /* 
  need functions to:
  1. fetch region by id (for now only id is 'sg')
  2. fetch place by id (place will be numbered with an id)
  */
  Future<Region> getRegionbyId(String regionId) async {
    final response = await dio.get('/regions/$regionId');

    switch (response.statusCode) {
      case 200:
        final data = response.data;
        if (data['success']) {
          final regionData = data['data'] ?? data['payload']?['data'];

          return Region.fromJson(regionData);
        } else {
          throw Exception(data['message'] ?? 'Failed to load region');
        }
      case 404:
        throw Exception('Region not found');
      default:
        throw Exception('Unexpected response: ${response.statusCode}');
    }
  }

  Future<Place> fetchPlacebyId(String placeId) async {
    final response = await dio.get('/location/find-by-id', queryParameters: {
      'id': placeId,
    });

    switch (response.statusCode) {
      case 200:
        final data = response.data;
        if (data['success']) {
          final placeData = data['payload']['data'];

          return Place.fromJson(placeData);
        } else {
          throw Exception(data['message'] ?? 'Failed to load place');
        }
      case 404:
        throw Exception('Place not found');
      default:
        throw Exception('Unexpected response: ${response.statusCode}');
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
      final response = await dio.post(
        '/location/search',
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Content-Type": "application/json",
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
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load filtered places: $e');
    }
  }

  Future<List<Review>> getReviewsForPlace(String placeId, Ref ref) async {
    return await ServiceHelpers.retryWithTokenRefresh(
        dio: dio,
        ref: ref,
        operation: () async {
          final response = await dio.get('/places/reviews/$placeId');

          switch (response.statusCode) {
            case 200:
              final data = response.data;
              if (data['success']) {
                final reviewsData = data['reviews'] ?? [];

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
        });
  }

  // Saved Places Methods
  Future<List<String>> getSavedPlaces(String userID) async {
    try {
      final response = await dio.get('/profile/saved-places', queryParameters: {
        'userID': userID,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          final placesData = data['payload']?['data'];
          if (placesData is List) {
            return List<String>.from(placesData);
          }
        }
      }
      return [];
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch saved places: $e');
    }
  }

  Future<bool> addSavedPlace(String userID, String placeID) async {
    try {
      final response = await dio.post('/profile/saved-places', data: {
        'userID': userID,
        'placeID': placeID,
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

  Future<bool> removeSavedPlace(String userID, String placeID) async {
    try {
      final response = await dio.delete('/profile/saved-places', data: {
        'userID': userID,
        'placeID': placeID,
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
      String userID, double lat, double lon) async {
    try {
      final response = await dio.get('/recommendation', queryParameters: {
        'userID': userID,
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
                .map((item) => int.parse(item['id']).toString())
                .toList();
          }
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
