import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/region.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

//this is an interface for fetching region data from database
class PlaceService {
  static final PlaceService _instance = PlaceService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;

  factory PlaceService() {
    return _instance;
  }
  PlaceService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          'Cache-Control': 'no-cache',
          'Access-Control-Allow-Origin': '*',
        },
      ),
    );
  }

  // Future<Region> getRegionbyId(String regionId) async {
  //   final response = await dio.get('/api/regions/$regionId');

  //   switch (response.statusCode) {
  //     case 200:
  //       final data = response.data;
  //       if (data['success']) {
  //         final regionData = data['data'] ?? data['payload']?['data'];

  //         return Region.fromJson(regionData);
  //       } else {
  //         throw Exception(data['message'] ?? 'Failed to load region');
  //       }
  //     case 404:
  //       throw Exception('Region not found');
  //     default:
  //       throw Exception('Unexpected response: ${response.statusCode}');
  //   }
  // }

  Future<Place> getPlaceByID(String placeId) async {
    final response = await dio.get('/location/$placeId');

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
  // Future<List<Place>> getAllPlaces(List<String> placesId) async {
  //   List<Place> places = [];
  //   for (String placeId in placesId) {
  //     try {
  //       Place place = await fetchPlacebyId(placeId);
  //       places.add(place);
  //     } catch (e) {
  //       print('Error fetching place $placeId: $e');
  //     }
  //   }
  //   return places;
  // }

  Future<List<Place>> getPlaceByImage(
      List<int> imageBytes, String filename) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });

      final response = await dio.post(
        '/location/search-by-image',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      final body = response.data as Map<String, dynamic>;
      switch (response.statusCode) {
        case 200:
          final locations = body['payload']?['data'] as List? ?? [];
          return locations.map((placeData) {
            return Place.fromJson(placeData as Map<String, dynamic>);
          }).toList();
        default:
          throw Exception(body['message'] ?? 'Failed to search by image');
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to search by image: $e');
    }
  }

  Future<List<Place>> getPlace(
      String query, List<String> options, String userID) async {
    try {
      final response = await dio.post(
        '/location/search',
        data: {
          'query': query,
          'options': options.join(','),
        },
      );
      final body = response.data;
      if (response.statusCode == 200) {
        // Validate response structure
        if (body is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final payload = body['payload'];
        if (payload == null || payload is! Map) {
          throw Exception('Missing or invalid payload');
        }

        final places = payload['data'];
        if (places == null) {
          return [];
        }

        if (places is! List) {
          throw Exception('Data is not a list');
        }

        final placesList = places.map((placeData) {
          if (placeData is! Map<String, dynamic>) {
            throw Exception('Invalid place data format');
          }
          return Place.fromJson(placeData);
        }).toList();

        return placesList;
      } else {
        final message = (body is Map && body['payload'] is Map)
            ? body['payload']['message'] ?? 'Unknown error'
            : 'Request failed with status ${response.statusCode}';
        throw Exception('Failed to load places: $message');
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load filtered places: $e');
    }
  }

  Future<List<Review>> getReviewsForPlace(String placeName, Ref ref) async {
    return await ServiceHelpers.retryWithTokenRefresh(
        dio: dio,
        ref: ref,
        operation: () async {
          final response = await dio.post('/api/ai/generate-reviews', data: {
            'place': placeName,
          });

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
                .map((item) => item['id'].toString())
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
