class Place {
  final String id;
  final String name;
  final Map<String, List<String>> tags;
  late String imageLink = '../../../assets/images/imagesx/$id.jpg';
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
    required this.description,
    required this.lat,
    required this.lon,
    required this.age,
    this.openHours,
    this.dayOff,
    this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    print('Place.fromJson input: $json');
    print('JSON keys: ${json.keys.toList()}');

    final place = Place(
      id: json['image id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      tags: _parseTags(json['tags']),
      //imageLink: json['imageLink'] ?? json['image_link'] ?? '',
      description: json['description'] ?? '',
      lat: (json['lat'] ?? json['latitude'] ?? 0).toDouble(),
      lon: (json['lon'] ?? json['longitude'] ?? 0).toDouble(),
      age: json['age'] ?? 0,
      openHours: _parseOpenHours(json['openHours']),
      dayOff: json['dayOff'],
    );

    print(
        'Created Place - id: ${place.id}, name: ${place.name}, lat: ${place.lat}, lon: ${place.lon}');
    return place;
  }

  static List<String>? _parseOpenHours(dynamic openHours) {
    if (openHours == null) return null;

    if (openHours is List) {
      return openHours.map((item) => item.toString()).toList();
    } else if (openHours is String) {
      // If it's a string, try to parse it as JSON
      try {
        return [openHours]; // Or parse if it's a JSON string
      } catch (e) {
        return null;
      }
    }

    return null;
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
      'image id': id,
      'name': name,
      'tags': tags,
      //'imageLink': imageLink,
      'description': description,
      'lat': lat,
      'lon': lon,
      'age': age,
      'openHours': openHours,
      'dayOff': dayOff,
    };
  }
}
