// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Events)
const eventsProvider = EventsProvider._();

final class EventsProvider extends $NotifierProvider<Events, List<Event>> {
  const EventsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'eventsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eventsHash();

  @$internal
  @override
  Events create() => Events();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Event> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Event>>(value),
    );
  }
}

String _$eventsHash() => r'08b4b7428c7348227c7b9403a9024dc19bba6f3e';

abstract class _$Events extends $Notifier<List<Event>> {
  List<Event> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Event>, List<Event>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Event>, List<Event>>, List<Event>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
