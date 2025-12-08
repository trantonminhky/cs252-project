import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';
import 'package:virtour_frontend/constants/userinfo.dart';

part 'trip_provider.g.dart';

@Riverpod(keepAlive: true)
class Trip extends _$Trip {
  final RegionService _regionService = RegionService();

  @override
  FutureOr<Set<Place>> build() async {
    final user = ref.watch(userSessionProvider);
    return await _loadSavedPlaces(user);
  }

  Future<Set<Place>> _loadSavedPlaces(UserInfo? user) async {
    if (user == null || user.userID.isEmpty) {
      return <Place>{};
    }

    try {
      final userID = user.userID;

      final placeIds = await _regionService.getSavedPlaces(userID);

      final places = <Place>{};
      for (final placeId in placeIds) {
        try {
          final place = await _regionService.fetchPlacebyId(placeId);
          places.add(place);
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

    // Add to local state immediately for better UX
    state = AsyncValue.data({...currentState, place});

    final user = ref.read(userSessionProvider);
    if (user == null || user.userID.isEmpty) {
      throw Exception("User is null");
    }

    // Sync with backend
    try {
      final userID = user.userID;
      final success = await _regionService.addSavedPlace(userID, place.id);

      if (!success) {
        // Revert if backend fails
        state = AsyncValue.data(currentState.where((p) => p != place).toSet());
        print('Failed to save place to backend');
      }
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentState.where((p) => p != place).toSet());
      print('Error saving place: $e');
    }
  }

  Future<void> removePlace(Place place) async {
    // Get current state
    final currentState = await future;

    // Remove from local state immediately
    state = AsyncValue.data(currentState.where((p) => p != place).toSet());

    final user = ref.read(userSessionProvider);
    if (user == null || user.userID.isEmpty) {
      throw Exception("User is null");
    }

    // Sync with backend
    try {
      final userID = user.userID;
      final success = await _regionService.removeSavedPlace(userID, place.id);

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
    ref.invalidateSelf();
    await future;
  }
}
