import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/frontend_service_layer/event_service.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

part 'participated_events_provider.g.dart';

@Riverpod(keepAlive: true)
class ParticipatedEvents extends _$ParticipatedEvents {
  @override
  FutureOr<Set<Event>> build() async {
    final events =
        (await EventService().fetchSubscribedEvents())?.toSet() ?? <Event>{};
    return events;
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
    state = await AsyncValue.guard(
        () async => (await EventService().fetchSubscribedEvents())?.toSet() ?? <Event>{});
  }
}
