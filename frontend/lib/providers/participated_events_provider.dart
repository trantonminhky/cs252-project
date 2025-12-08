import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';
import 'package:virtour_frontend/frontend_service_layer/place_service.dart';
import 'package:virtour_frontend/global/userinfo.dart';

part 'participated_events_provider.g.dart';

@Riverpod(keepAlive: true)
class ParticipatedEvents extends _$ParticipatedEvents {
  @override
  FutureOr<Set<Event>> build() async {
    return await _loadSubscribedEvents();
  }

  Future<Set<Event>> _loadSubscribedEvents() async {
    final username = UserInfo().email;
    if (username.isEmpty) {
      return {};
    }

    try {
      final eventsData = await RegionService().fetchSubscribedEvents(username);
      final Set<Event> events = {};

      for (var eventData in eventsData) {
        try {
          events.add(Event(
            id: eventData['id'].toString(),
            name: eventData['name'] ?? 'Unnamed Event',
            location: eventData['location'] ?? 'TBD',
            description: eventData['description'] ?? '',
            startTime: eventData['startTime'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    eventData['startTime'] as int)
                : DateTime.now(),
            endTime: eventData['endTime'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    eventData['endTime'] as int)
                : DateTime.now(),
            imageUrl: eventData['imageLink'] ?? '',
            numberOfPeople: (eventData['participants'] as List?)?.length ?? 0,
          ));
        } catch (e) {
          print('Error parsing subscribed event: $e');
        }
      }

      return events;
    } catch (e) {
      print('Error loading subscribed events: $e');
      return {};
    }
  }

  Future<void> addEvent(Event event) async {
    final currentState = await future;
    state = AsyncValue.data({...currentState, event});
  }

  Future<void> removeEvent(String eventId) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.where((e) => e.id != eventId).toSet());
  }

  bool isParticipating(String eventId) {
    return state.value?.any((e) => e.id == eventId) ?? false;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadSubscribedEvents());
  }
}
