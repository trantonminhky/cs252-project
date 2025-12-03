// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participated_events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ParticipatedEvents)
const participatedEventsProvider = ParticipatedEventsProvider._();

final class ParticipatedEventsProvider
    extends $AsyncNotifierProvider<ParticipatedEvents, Set<Event>> {
  const ParticipatedEventsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'participatedEventsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$participatedEventsHash();

  @$internal
  @override
  ParticipatedEvents create() => ParticipatedEvents();
}

String _$participatedEventsHash() =>
    r'37d5acfce6b751016824823b9880dddd6bd84659';

abstract class _$ParticipatedEvents extends $AsyncNotifier<Set<Event>> {
  FutureOr<Set<Event>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Set<Event>>, Set<Event>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Set<Event>>, Set<Event>>,
        AsyncValue<Set<Event>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
