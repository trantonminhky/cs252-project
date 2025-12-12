import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/frontend_service_layer/event_service.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

part 'event_provider.g.dart';

@Riverpod(keepAlive: true)
class Events extends _$Events {
  @override
  FutureOr<List<Event>> build() async {
    ref.watch(userSessionProvider);
    return await EventService().fetchEvents() ?? List<Event>.empty();
  }

  Future<void> addEvent(Event event) async {
    // Call backend API to create event
    final result = await EventService().createEvent(
      name: event.name,
      location: event.location,
      description: event.description,
      imageLink: event.imageUrl,
      startTime: event.startTime.millisecondsSinceEpoch,
      endTime: event.endTime.millisecondsSinceEpoch,
    );

    if (result != null) {
      // Update local state with the event from backend (which has the server-generated ID)
      final serverEvent = Event(
        id: result['id']?.toString() ?? event.id,
        name: result['name'] ?? event.name,
        location: result['location'] ?? event.location,
        description: result['description'] ?? event.description,
        startTime: result['startTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(result['startTime'])
            : event.startTime,
        endTime: result['endTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(result['endTime'])
            : event.endTime,
        imageUrl: result['imageLink'] ?? event.imageUrl,
        numberOfPeople: (result['participants'] as List?)?.length ?? 0,
      );

      final currentState = await future;
      state = AsyncValue.data([...currentState, serverEvent]);
    } else {
      throw Exception('Failed to create event on server');
    }
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
    ref.invalidateSelf();
    await future;
  }
}
