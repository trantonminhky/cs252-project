import "package:virtour_frontend/screens/data_factories/filter_type.dart";

class Place {
  final String id;
  final String name;
  final Map<FilterType, List<CategoryType>> tags;
  final String imageLink;
  final double lat;
  final double lon;
  final String description;
  final int age;
  final String openHours;
  final String dayOff;

  Place({
    required this.id,
    required this.name,
    required this.tags,
    required this.imageLink,
    required this.description,
    required this.lat,
    required this.lon,
    required this.age,
    required this.openHours,
    required this.dayOff,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parse tags from JSON
    Map<FilterType, List<CategoryType>> parsedTags = {};

    if (json['tags'] != null && json['tags'] is Map) {
      final tagsMap = json['tags'] as Map<String, dynamic>;
      tagsMap.forEach((key, value) {
        // Convert string key to FilterType enum
        final filterType = FilterType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => FilterType.regionOverview,
        );

        // Convert list of strings to CategoryType enums
        final categories = (value as List)
            .map((cat) => CategoryType.values.firstWhere(
                  (e) => e.name == cat.toString(),
                  orElse: () => CategoryType.landmark,
                ))
            .toList();

        parsedTags[filterType] = categories;
      });
    }

    return Place(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      tags: parsedTags,
      imageLink: json['imageLink'] ?? json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      lat: (json['lat'] ?? json['latitude'] ?? 0).toDouble(),
      lon: (json['lon'] ?? json['longitude'] ?? 0).toDouble(),
      age: json['age'] ?? 0,
      openHours: json['openHours'] ?? '',
      dayOff: json['dayOff'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Convert tags map to JSON-serializable format
    Map<String, List<String>> tagsJson = {};
    tags.forEach((filterType, categories) {
      tagsJson[filterType.name] = categories.map((cat) => cat.name).toList();
    });

    return {
      'id': id,
      'name': name,
      'tags': tagsJson,
      'imageLink': imageLink,
      'description': description,
      'lat': lat,
      'lon': lon,
      'age': age,
      'openHours': openHours,
      'dayOff': dayOff,
    };
  }
}
