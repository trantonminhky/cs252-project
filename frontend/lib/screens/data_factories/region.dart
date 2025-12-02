class Region {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> placesId;
  final String? category;

  const Region({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.placesId,
    this.category,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      description: json['description'] ?? '',
      placesId: (json['placesId'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['places'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'placesId': placesId,
      'category': category,
    };
  }
}
