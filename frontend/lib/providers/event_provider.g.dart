// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Events)
const eventsProvider = EventsProvider._();

final class EventsProvider extends $AsyncNotifierProvider<Events, List<Event>> {
  const EventsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'eventsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eventsHash();

  @$internal
  @override
  Events create() => Events();
}

String _$eventsHash() => r'164322139e5a2bd200781e71987d55d4d685eb08';

abstract class _$Events extends $AsyncNotifier<List<Event>> {
  FutureOr<List<Event>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Event>>, List<Event>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Event>>, List<Event>>,
        AsyncValue<List<Event>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
