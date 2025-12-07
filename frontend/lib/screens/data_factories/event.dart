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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
