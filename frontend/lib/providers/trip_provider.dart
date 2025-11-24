import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';

part 'trip_provider.g.dart';

@riverpod
class Trip extends _$Trip {
  @override
  Set<Place> build() {
    return {};
  }

  void addPlace(Place place) {
    state = {...state, place};
  }

  void removePlace(Place place) {
    state = state.where((p) => p != place).toSet();
  }
}
