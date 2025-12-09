import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';
import 'package:virtour_frontend/global/userinfo.dart';

part 'trip_provider.g.dart';

@Riverpod(keepAlive: true)
class Trip extends _$Trip {
  final RegionService _regionService = RegionService();

  final Map<String, Place> _placeCache = {};

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
          if (_placeCache.containsKey(placeId)) {
            places.add(_placeCache[placeId]!);
          } else {
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
    final currentState = await future;

    _placeCache[place.id] = place;

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
        _placeCache.remove(place.id);
        state = AsyncValue.data(currentState.where((p) => p != place).toSet());
        print('Failed to save place to backend');
      }
    } catch (e) {
      _placeCache.remove(place.id);
      state = AsyncValue.data(currentState.where((p) => p != place).toSet());
      print('Error saving place: $e');
    }
  }

  Future<void> removePlace(Place place) async {
    final currentState = await future;

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
        state = AsyncValue.data({...currentState, place});
        print('Failed to remove place from backend');
      }
    } catch (e) {
      state = AsyncValue.data({...currentState, place});
      print('Error removing place: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
