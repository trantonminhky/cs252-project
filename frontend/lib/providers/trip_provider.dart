import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';
import 'package:virtour_frontend/screens/data_factories/data_service.dart';
import 'package:virtour_frontend/constants/userinfo.dart';

part 'trip_provider.g.dart';

@riverpod
class Trip extends _$Trip {
  final RegionService _regionService = RegionService();
  final UserInfo _userInfo = UserInfo();

  @override
  Set<Place> build() {
    // Load saved places from backend on initialization
    _loadSavedPlaces();
    return {};
  }

  Future<void> _loadSavedPlaces() async {
    try {
      // Get username (you may need to adjust this based on your auth implementation)
      final username =
          _userInfo.username.isNotEmpty ? _userInfo.username : 'guest';

      final placeIds = await _regionService.getSavedPlaces(username);

      // Fetch full place details for each saved place
      final places = <Place>{};
      for (final placeId in placeIds) {
        try {
          final place = await _regionService.fetchPlacebyId(placeId);
          places.add(place);
        } catch (e) {
          print('Error loading saved place $placeId: $e');
        }
      }

      state = places;
    } catch (e) {
      print('Error loading saved places: $e');
    }
  }

  Future<void> addPlace(Place place) async {
    // Add to local state immediately for better UX
    state = {...state, place};

    // Sync with backend
    try {
      final username =
          _userInfo.username.isNotEmpty ? _userInfo.username : 'guest';
      final success = await _regionService.addSavedPlace(username, place.id);

      if (!success) {
        // Revert if backend fails
        state = state.where((p) => p != place).toSet();
        print('Failed to save place to backend');
      }
    } catch (e) {
      // Revert on error
      state = state.where((p) => p != place).toSet();
      print('Error saving place: $e');
    }
  }

  Future<void> removePlace(Place place) async {
    // Remove from local state immediately
    state = state.where((p) => p != place).toSet();

    // Sync with backend
    try {
      final username =
          _userInfo.username.isNotEmpty ? _userInfo.username : 'guest';
      final success = await _regionService.removeSavedPlace(username, place.id);

      if (!success) {
        // Revert if backend fails
        state = {...state, place};
        print('Failed to remove place from backend');
      }
    } catch (e) {
      // Revert on error
      state = {...state, place};
      print('Error removing place: $e');
    }
  }

  // Refresh from backend
  Future<void> refresh() async {
    await _loadSavedPlaces();
  }
}
