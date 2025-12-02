import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/services/service_exception_handler.dart";

//this is an interface for fetching region data from database
class RegionService {
  static final RegionService _instance = RegionService._internal();
  late final Dio dio;
  static const String _baseUrl =
      "https://scenic-descending-finger-politicians.trycloudflare.com";
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

  Future<List<Place>> getPlace(String query, List<String> includeFilter) async {
    try {
      final queryParams = {
        'query': query,
        'include': includeFilter.join(','),
      };
      final response = await dio.get(
        '/api/location/search',
        queryParameters: queryParams,
      );
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
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Failed to load filtered places: $e');
    }
  }

  Future<List<Review>> getReviewsForPlace(String placeId) async {
    try {
      final response = await dio.get('/api/locations/reviews/$placeId');

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
}
