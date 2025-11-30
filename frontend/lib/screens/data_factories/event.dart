class Event {
  final String id;
  final String name;
  final String location;
  final String description;
  final DateTime time;
  final String imageUrl;
  final int numberOfPeople;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.time,
    required this.imageUrl,
    required this.numberOfPeople,
  });

  factory Event.fromBson(Map<String, dynamic> bson) {
    return Event(
      id: bson['_id'].toString(),
      name: bson['name'],
      location: bson['location'],
      description: bson['description'],
      time: DateTime.parse(bson['time']),
      imageUrl: bson['imageUrl'],
      numberOfPeople: bson['numberOfPeople'],
    );
  }

  Map<String, dynamic> toBson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'description': description,
      'time': time.toIso8601String(),
      'imageUrl': imageUrl,
      'numberOfPeople': numberOfPeople,
    };
  }
}
