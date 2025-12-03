class Event {
  final String id;
  final String name;
  final String location;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String imageUrl;
  final int numberOfPeople;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    required this.numberOfPeople,
  });

  factory Event.fromBson(Map<String, dynamic> bson) {
    return Event(
      id: bson['_id'].toString(),
      name: bson['name'],
      location: bson['location'],
      description: bson['description'],
      startTime: DateTime.parse(bson['startTime']),
      endTime: DateTime.parse(bson['endTime']),
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
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'imageUrl': imageUrl,
      'numberOfPeople': numberOfPeople,
    };
  }
}
