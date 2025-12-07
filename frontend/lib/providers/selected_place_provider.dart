import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/place.dart';

part 'selected_place_provider.g.dart';

@riverpod
class SelectedPlace extends _$SelectedPlace {
  @override
  Place? build() {
    return null;
  }

  void setPlace(Place? place) {
    state = place;
  }

  void clearPlace() {
    state = null;
  }
}
