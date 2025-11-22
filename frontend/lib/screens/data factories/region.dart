import "place.dart";

class Region {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> placesId;

  const Region({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.placesId,
  });

  factory Region.fromBson(Map<String, dynamic> bson) {
    return Region(
      id: bson['_id'].toString(),
      name: bson['name'],
      imageUrl: bson['imageUrl'],
      description: bson['description'],
      placesId: List<String>.from(bson['placesId']),
    );
  }

  Map<String, dynamic> toBson() {
    return {
      '_id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'placesId': placesId,
    };
  }
}
