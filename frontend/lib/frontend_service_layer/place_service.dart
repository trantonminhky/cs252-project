import "package:virtour_frontend/screens/data_factories/place.dart";
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
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          'Cache-Control': 'no-cache',
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
        '$_baseUrl/api/location/search',
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
}
