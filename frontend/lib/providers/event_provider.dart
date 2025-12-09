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
    ref.invalidateSelf();
    await future;
  }
}
