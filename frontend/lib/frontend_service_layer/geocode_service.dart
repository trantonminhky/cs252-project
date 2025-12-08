import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

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
    ServiceHelpers.addAuthInterceptor(dio);
  }

  Future<Place?> geocodeAddress(String address) async {
    try {
      return await ServiceHelpers.retryWithTokenRefresh(
        dio: dio,
        operation: () async {
          final response = await dio.get(
            '$_baseUrl/api/geocode/geocode',
            queryParameters: {
              'address': address,
              'credentials': UserInfo().accessToken
            },
          );
          final body = response.data as Map<String, dynamic>;
          if (response.statusCode == 200 && body['place'] != null) {
            return Place.fromJson(body['place']);
          } else {
            return null;
          }
        },
      );
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      return await ServiceHelpers.retryWithTokenRefresh(
        dio: dio,
        operation: () async {
          final response = await dio.get(
            '$_baseUrl/api/geocode/reverse-geocode',
            queryParameters: {
              'lat': lat,
              'lon': lon,
              'credentials': UserInfo().accessToken,
            },
          );
          final body = response.data as Map<String, dynamic>;
          if (response.statusCode == 200 &&
              body['payload']['address'] != null) {
            return body['payload']['address'] as String;
          } else {
            return null;
          }
        },
      );
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}
