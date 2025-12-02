import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

part 'participated_events_provider.g.dart';

@riverpod
class ParticipatedEvents extends _$ParticipatedEvents {
  @override
  Set<Event> build() {
    return {};
  }

  void addEvent(Event event) {
    state = {...state, event};
  }

  void removeEvent(Event event) {
    state = state.where((e) => e.id != event.id).toSet();
  }

  bool isParticipating(String eventId) {
    return state.any((e) => e.id == eventId);
  }
}
