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
    extends $NotifierProvider<ParticipatedEvents, Set<Event>> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<Event> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<Event>>(value),
    );
  }
}

String _$participatedEventsHash() =>
    r'1b36c5fd9da911af0d716adc5b9fa9161fda67ea';

abstract class _$ParticipatedEvents extends $Notifier<Set<Event>> {
  Set<Event> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<Event>, Set<Event>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<Event>, Set<Event>>, Set<Event>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
