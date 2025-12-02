import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

class GeocodeService {
  static final GeocodeService _instance = GeocodeService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo().tunnelUrl;

  factory GeocodeService() {
    return _instance;
  }

  GeocodeService._internal() {
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
    _addAuthInterceptor();
  }

  Future<void> _addAuthInterceptor() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          //final prefs = await SharedPreferences.getInstance();
          final token = UserInfo().userSessionToken;
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  Future<Place?> geocodeAddress(String address) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/geocode/geocode',
        queryParameters: {
          'address': address,
          'credentials': UserInfo().userSessionToken
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (response.statusCode == 200 && body['place'] != null) {
        return Place.fromJson(body['place']);
      } else {
        return null;
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/geocode/reverse-geocode',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'credentials': UserInfo().userSessionToken,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (response.statusCode == 200 && body['address'] != null) {
        return body['address'] as String;
      } else {
        return null;
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}
