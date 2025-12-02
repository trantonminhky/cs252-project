class Place {
  final String id;
  final String name;
  final Map<String, List<String>> tags;
  final String imageLink;
  final double lat;
  final double lon;
  final String description;
  final int age;
  final List<String>? openHours;
  final String? dayOff;
  late String address;

  Place({
    required this.id,
    required this.name,
    required this.tags,
    required this.imageLink,
    required this.description,
    required this.lat,
    required this.lon,
    required this.age,
    this.openHours,
    this.dayOff,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> parsedTags = {};

    if (json['tags'] != null && json['tags'] is Map) {
      final tagsMap = json['tags'] as Map<String, dynamic>;
      tagsMap.forEach((key, value) {
        parsedTags[key] =
            (value as List).map((item) => item.toString()).toList();
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
      openHours: json['openHours'] != null
          ? List<String>.from(json['openHours'])
          : null,
      dayOff: json['dayOff'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tags': tags,
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
