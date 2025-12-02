import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';

part 'event_provider.g.dart';

@Riverpod(keepAlive: true)
class Events extends _$Events {
  @override
  FutureOr<List<Event>> build() async {
    return await _fetchEventsFromDB();
  }

  Future<List<Event>> _fetchEventsFromDB() async {
    final eventsData = await RegionService().fetchEvents();
    final List<Event> eventsList = [];

    eventsData.forEach((key, value) {
      try {
        eventsList.add(Event(
          id: key,
          name: value['name'] ?? 'Unnamed Event',
          location: value['location'] ?? 'TBD',
          description: value['description'] ?? '',
          startTime: value['startTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(value['startTime'] as int)
              : DateTime.now(),
          endTime: value['endTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(value['endTime'] as int)
              : DateTime.now(),
          imageUrl: value['imageLink'] ?? '',
          numberOfPeople: (value['participants'] as List?)?.length ?? 0,
        ));
      } catch (e) {
        print('Error parsing event $key: $e');
      }
    });

    return eventsList;
  }

  Future<void> addEvent(Event event) async {
    final currentState = await future;
    state = AsyncValue.data([...currentState, event]);
  }

  Future<void> removeEvent(Event event) async {
    final currentState = await future;
    state = AsyncValue.data(
      currentState.where((e) => e.id != event.id).toList(),
    );
  }

  Future<void> updateEvent(Event updatedEvent) async {
    final currentState = await future;
    state = AsyncValue.data(
      currentState
          .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
          .toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetchEventsFromDB());
  }
}
