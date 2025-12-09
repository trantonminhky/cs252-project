import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

class GeocodeService {
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;
  final Ref ref;

  GeocodeService({required String token, required this.ref}) {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  Future<Place?> geocodeAddress(String address) async {
    try {
      return await ServiceHelpers.retryWithTokenRefresh(
        dio: dio,
        ref: ref,
        operation: () async {
          final response = await dio.get(
            '$_baseUrl/api/geocode/geocode',
            queryParameters: {
              'address': address,
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
        ref: ref,
        operation: () async {
          final response = await dio.get(
            '$_baseUrl/api/geocode/reverse-geocode',
            queryParameters: {
              'lat': lat,
              'lon': lon,
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
