import "package:dio/dio.dart";
import "package:latlong2/latlong.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

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

      if (response.statusCode != 200) {
        throw Exception('Failed to get route');
      }

      final data = response.data;
      if (!data['success']) {
        throw Exception(data['payload']['message'] ?? 'Failed to get route');
      }

      final routeData = data['payload']['data'];

      // Parse the route coordinates from the response
      // OpenRouteService returns features with geometry.coordinates
      final features = routeData['features'] as List;
      if (features.isEmpty) {
        throw Exception('No route found');
      }

      final geometry = features[0]['geometry'];
      final coordinates = geometry['coordinates'] as List;

      // Convert to LatLng list
      final routePoints = coordinates.map((coord) {
        return LatLng(coord[1] as double, coord[0] as double);
      }).toList();

      // Extract distance and duration from properties
      final properties = features[0]['properties'];
      final summary = properties['summary'];
      final distance = summary['distance'] as double; // in meters
      final duration = summary['duration'] as double; // in seconds

      return RouteResult(
        points: routePoints,
        distance: distance,
        duration: duration,
      );
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Error getting route: $e');
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

  /// Get distance in kilometers
  double get distanceKm => distance / 1000;

  /// Get duration in minutes
  double get durationMinutes => duration / 60;

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Get formatted duration string
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
