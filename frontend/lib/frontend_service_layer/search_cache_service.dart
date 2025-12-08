import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "package:virtour_frontend/screens/data_factories/place.dart";

class SearchCacheService {
  final String key = "search_cache";
  final int maxItems = 10;

  SearchCacheService();

  Future<List<Place>> getCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(key) ?? [];
    return jsonStringList
        .map((jsonString) => Place.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> writeCache(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final encode = places.map((place) => jsonEncode(place.toJson())).toList();
    await prefs.setStringList(key, encode);
  }

  Future<void> addCache(Place place) async {
    final existing = await getCache();

    existing.removeWhere((p) => p.id == place.id);
    existing.insert(0, place);

    if (existing.length > maxItems) {
      existing.removeLast();
    }

    await writeCache(existing);
  }
}
