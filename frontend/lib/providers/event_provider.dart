import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

part 'event_provider.g.dart';

@riverpod
class Events extends _$Events {
  @override
  List<Event> build() {
    return [
      Event(
        id: "1",
        name: "Saigon Heritage Festival",
        location: "...",
        description: "Experience the rich cultural heritage of Saigon",
        startTime: DateTime(2025, 12, 15, 18, 0),
        endTime: DateTime(2025, 12, 15, 22, 0),
        imageUrl: "../assets/images/places/Saigon.png",
        numberOfPeople: 250,
      ),
      Event(
        id: "2",
        name: "Hanoi Food Night Market",
        location: "...",
        description: "Explore traditional Vietnamese cuisine",
        startTime: DateTime(2025, 12, 10, 19, 30),
        endTime: DateTime(2025, 12, 10, 23, 0),
        imageUrl: "../assets/images/places/Ha_Noi.jpg",
        numberOfPeople: 180,
      ),
    ];
  }

  void addEvent(Event event) {
    state = [...state, event];
  }

  void removeEvent(Event event) {
    state = state.where((e) => e.id != event.id).toList();
  }

  void updateEvent(Event updatedEvent) {
    state =
        state.map((e) => e.id == updatedEvent.id ? updatedEvent : e).toList();
  }
}
