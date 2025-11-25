import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/region.dart';

part 'regions_visited_provider.g.dart';

@riverpod
class RegionsVisited extends _$RegionsVisited {
  @override
  Set<Region> build() {
    return {
      Region(
        id: "01",
        name: "Sài Gòn",
        imageUrl: "assets/images/places/Saigon.png",
        description: "...",
        placesId: List.empty(),
      ),
      Region(
        id: "02",
        name: "Ha Noi",
        imageUrl: "assets/images/places/Ha_Noi.jpg",
        description: "...",
        placesId: List.empty(),
      ),
    };
  }

  void addRegion(Region region) {
    state = {...state, region};
  }

  void removeRegion(Region region) {
    state = state.where((r) => r != region).toSet();
  }
}
