import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';
import 'package:virtour_frontend/global/userinfo.dart';

part 'trip_provider.g.dart';

@Riverpod(keepAlive: true)
class Trip extends _$Trip {
  final RegionService _regionService = RegionService();
  final UserInfo _userInfo = UserInfo();

  final Map<String, Place> _placeCache = {};

  @override
  FutureOr<Set<Place>> build() async {
    return await _loadSavedPlaces();
  }

  Future<Set<Place>> _loadSavedPlaces() async {
    try {
      final username = _userInfo.username.isNotEmpty ? _userInfo.username : 'guest';

      final placeIds = await _regionService.getSavedPlaces(username);

      final validPlaceIds =
          placeIds.where((id) => !id.startsWith('event_')).toList();

      final places = <Place>{};
      for (final placeId in validPlaceIds) {
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

    try {
      final username = _userInfo.email.isNotEmpty ? _userInfo.email : 'guest';
      final success = await _regionService.addSavedPlace(username, place.id);

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

    try {
      final username = _userInfo.email.isNotEmpty ? _userInfo.email : 'guest';
      final success = await _regionService.removeSavedPlace(username, place.id);

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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadSavedPlaces());
  }
}
