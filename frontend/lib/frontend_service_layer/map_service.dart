import "package:dio/dio.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/global/userinfo.dart";

class MapService {
  static final MapService _instance = MapService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;

  factory MapService() {
    return _instance;
  }

  MapService._internal() {
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
  }

  /// Get route between two coordinates
  /// Returns a list of LatLng points representing the route polyline
  Future<RouteResult> getRoute({
    required LatLng from,
    required LatLng to,
    required String token,
    String profile = 'driving-car',
  }) async {
    try {
      final response = await dio.post(
        "$_baseUrl/api/map/route",
        data: {
          "coordinates": [
            [from.longitude, from.latitude],
            [to.longitude, to.latitude]
          ],
          "profile": profile,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      // 1. Validate Status Code
      if (response.statusCode != 200) {
        throw Exception('Failed to get route: Status ${response.statusCode}');
      }

      final data = response.data;

      // 2. SAFETY CHECK: Ensure data is a Map
      // If the server returns a List (e.g. valid JSON array), accessing ['success'] crashes.
      if (data is List) {
        print("DEBUG: API returned a List: $data");
        throw Exception('Unexpected API response format (List)');
      }
      if (data is! Map) {
         throw Exception('Unexpected API response format (Not a Map)');
      }

      // 3. Handle Backend Error Response
      // Backend MapService.js returns success: false on error.
      if (data['success'] != true) {
        final payload = data['payload'];
        
        // Backend MapService.js line 70 sends err.toString() as payload.
        // We must handle String payloads specifically.
        if (payload is String) {
          throw Exception(payload);
        }
        
        // Handle Map payloads
        if (payload is Map && payload.containsKey('message')) {
          throw Exception(payload['message']);
        }

        throw Exception('Failed to get route (Unknown Error)');
      }

      // 4. Locate Route Data
      // Backend sends `axiosResponse.data` as payload.
      // Depending on ServiceResponse implementation, it might be in `payload` OR `payload['data']`.
      Map<String, dynamic> routeData;
      
      if (data['payload'] is Map && data['payload'].containsKey('features')) {
        // Case A: Payload IS the route data (Matches MapService.js logic)
        routeData = data['payload'];
      } else if (data['payload'] is Map && 
                 data['payload']['data'] is Map && 
                 data['payload']['data'].containsKey('features')) {
        // Case B: Payload contains a 'data' key with route data
        routeData = data['payload']['data'];
      } else {
         throw Exception('Route data (features) is missing from response');
      }

      // 5. Parse Features
      final features = routeData['features'];
      if (features is! List || features.isEmpty) {
        throw Exception('No route found (Empty features)');
      }

      final geometry = features[0]['geometry'];
      if (geometry == null || geometry['coordinates'] == null) {
        throw Exception('Invalid route geometry');
      }

      final coordinates = geometry['coordinates'] as List;

      // 6. Safe Coordinate Parsing (Handle Int vs Double)
      final routePoints = coordinates.map((coord) {
        final List point = coord as List;
        return LatLng(
          (point[1] as num).toDouble(), // Latitude
          (point[0] as num).toDouble(), // Longitude
        );
      }).toList();

      // 7. Safe Summary Parsing
      final properties = features[0]['properties'];
      final summary = properties['summary'];
      
      final distance = (summary['distance'] as num).toDouble(); 
      final duration = (summary['duration'] as num).toDouble(); 

      return RouteResult(
        points: routePoints,
        distance: distance,
        duration: duration,
      );

    } on DioException catch (e) {
      // Handle Dio errors specifically
      String errorMsg = e.message ?? "Network error";
      if (e.response?.data is Map) {
         final errData = e.response?.data;
         if (errData['payload'] is String) {
           errorMsg = errData['payload'];
         } else if (errData['payload'] is Map && errData['payload']['message'] != null) {
           errorMsg = errData['payload']['message'];
         }
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}

/// Result object containing route information
class RouteResult {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds

  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
  });

  double get distanceKm => distance / 1000;
  double get durationMinutes => duration / 60;

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = durationMinutes.round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }
}