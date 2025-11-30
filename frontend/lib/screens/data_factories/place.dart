import "package:virtour_frontend/screens/data_factories/filter_type.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";

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
  final List<Review> reviews;

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
    required this.reviews,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'].toString(),
      name: json['name'],
      categories: List<String>.from(json['categories']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      type: FilterType.values[json['type']],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      reviews: (json['review'] as List).map((e) => Review.fromJson(e)).toList(),
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
      'review': reviews.map((e) => e.toJson()).toList(),
    };
  }
}
