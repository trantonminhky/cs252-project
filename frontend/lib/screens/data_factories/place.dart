import "package:virtour_frontend/screens/data_factories/filter_type.dart";

class Place {
  final String id;
  final String name;
  final List<String> categories;
  final String imageUrl;
  final String description;
  final FilterType type;
  final double latitude;
  final double longitude;
  final String address;

  Place({
    required this.id,
    required this.name,
    required this.categories,
    required this.imageUrl,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Handle location data structure from LocationService
    if (json.containsKey('lat') && json.containsKey('lon')) {
      // Convert tags to categories list
      List<String> categories = [];
      if (json['tags'] != null && json['tags'] is Map) {
        final tags = json['tags'] as Map<String, dynamic>;

        // Extract all tag types into categories
        tags.forEach((key, value) {
          if (value != null && value is List && value.isNotEmpty) {
            for (var item in value) {
              if (item is String) {
                categories.add(item);
              }
            }
          }
        });
      }

      // Determine FilterType from tags
      FilterType placeType = FilterType.religion; // default
      if (categories.isNotEmpty) {
        if (categories.any((tag) =>
            tag.toLowerCase().contains('temple') ||
            tag.toLowerCase().contains('church') ||
            tag.toLowerCase().contains('mosque') ||
            tag.toLowerCase().contains('worship') ||
            tag.toLowerCase().contains('religion'))) {
          placeType = FilterType.religion;
        }
      }

      return Place(
        id: json['id'].toString(),
        name: json['name'] ?? 'Unknown',
        categories: categories,
        imageUrl: json['imageLink'] ?? '',
        description: json['description'] ?? '',
        type: placeType,
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lon'] as num).toDouble(),
        address: json['name'] ??
            '', // Using name as address since address field doesn't exist
      );
    }

    // Handle original Place data structure
    return Place(
      id: json['_id'].toString(),
      name: json['name'],
      categories: List<String>.from(json['categories'] ?? []),
      imageUrl: json['imageUrl'],
      description: json['description'],
      type: json['type'] is int
          ? FilterType.values[json['type']]
          : FilterType.religion, // default fallback
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'categories': categories,
      'imageUrl': imageUrl,
      'description': description,
      'type': type.index,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
