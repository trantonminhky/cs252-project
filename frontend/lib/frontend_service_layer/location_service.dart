import "package:geolocator/geolocator.dart";
import "package:latlong2/latlong.dart";

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    print('Location service enabled: $enabled');
    return enabled;
  }

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print('Current permission: $permission');

    if (permission == LocationPermission.denied) {
      print('Requesting permission...');
      permission = await Geolocator.requestPermission();
      print('Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        print('Permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission denied forever');
      return false;
    }

    print('Permission granted');
    return true;
  }

  /// Get current location
  /// Returns null if location cannot be determined
  Future<LatLng?> getCurrentLocation() async {
    try {
      print('Starting to get current location...');

      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location service not enabled');
        return null;
      }

      // Check permissions
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        print('No location permission');
        return null;
      }

      print('Getting position...');
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      print('Got location: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get location stream for real-time updates
  Stream<LatLng> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
