import "package:virtour_frontend/screens/data factories/filter_type.dart";

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

  factory Place.fromBson(Map<String, dynamic> bson) {
    return Place(
      id: bson['_id'].toString(),
      name: bson['name'],
      categories: List<String>.from(bson['categories']),
      imageUrl: bson['imageUrl'],
      description: bson['description'],
      type: FilterType.values[bson['type']],
      latitude: bson['latitude'],
      longitude: bson['longitude'],
      address: bson['address'],
    );
  }

  Map<String, dynamic> toBson() {
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
