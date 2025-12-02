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
  String? address;

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
    this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      tags: _parseTags(json['tags']),
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

  static Map<String, List<String>> _parseTags(dynamic tags) {
    final parsedTags = <String, List<String>>{};

    if (tags != null && tags is Map) {
      tags.forEach((key, value) {
        if (value is List) {
          parsedTags[key.toString()] =
              value.map((item) => item.toString()).toList();
        }
      });
    }

    return parsedTags;
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
