import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';
import 'package:virtour_frontend/global/userinfo.dart';

part 'trip_provider.g.dart';

@Riverpod(keepAlive: true)
class Trip extends _$Trip {
  final RegionService _regionService = RegionService();
  final UserInfo _userInfo = UserInfo();

  // Cache to avoid repeated HTTP calls for the same place
  final Map<String, Place> _placeCache = {};

  @override
  FutureOr<Set<Place>> build() async {
    return await _loadSavedPlaces();
  }

  Future<Set<Place>> _loadSavedPlaces() async {
    try {
      final username = _userInfo.email.isNotEmpty ? _userInfo.email : 'guest';

      final placeIds = await _regionService.getSavedPlaces(username);

      // Filter out event_ prefixed IDs as they don't exist in place database
      final validPlaceIds =
          placeIds.where((id) => !id.startsWith('event_')).toList();

      // Fetch full place details for each saved place using cache
      final places = <Place>{};
      for (final placeId in validPlaceIds) {
        try {
          // Check cache first to avoid repeated HTTP calls
          if (_placeCache.containsKey(placeId)) {
            places.add(_placeCache[placeId]!);
          } else {
            // Fetch from API and cache the result
            final place = await _regionService.fetchPlacebyId(placeId);
            _placeCache[placeId] = place;
            places.add(place);
          }
        } catch (e) {
          print('Error loading saved place $placeId: $e');
        }
      }

      return places;
    } catch (e) {
      print('Error loading saved places: $e');
      return {};
    }
  }

  Future<void> addPlace(Place place) async {
    // Get current state
    final currentState = await future;

    // Add to cache
    _placeCache[place.id] = place;

    // Add to local state immediately for better UX
    state = AsyncValue.data({...currentState, place});

    // Sync with backend
    try {
      final username = _userInfo.email.isNotEmpty ? _userInfo.email : 'guest';
      final success = await _regionService.addSavedPlace(username, place.id);

      if (!success) {
        // Revert if backend fails
        _placeCache.remove(place.id);
        state = AsyncValue.data(currentState.where((p) => p != place).toSet());
        print('Failed to save place to backend');
      }
    } catch (e) {
      // Revert on error
      _placeCache.remove(place.id);
      state = AsyncValue.data(currentState.where((p) => p != place).toSet());
      print('Error saving place: $e');
    }
  }

  Future<void> removePlace(Place place) async {
    // Get current state
    final currentState = await future;

    // Remove from local state immediately
    state = AsyncValue.data(currentState.where((p) => p != place).toSet());

    // Sync with backend
    try {
      final username = _userInfo.email.isNotEmpty ? _userInfo.email : 'guest';
      final success = await _regionService.removeSavedPlace(username, place.id);

      if (!success) {
        // Revert if backend fails
        state = AsyncValue.data({...currentState, place});
        print('Failed to remove place from backend');
      }
    } catch (e) {
      // Revert on error
      state = AsyncValue.data({...currentState, place});
      print('Error removing place: $e');
    }
  }

  // Refresh from backend
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadSavedPlaces());
  }
}
