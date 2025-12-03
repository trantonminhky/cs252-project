// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Trip)
const tripProvider = TripProvider._();

final class TripProvider extends $AsyncNotifierProvider<Trip, Set<Place>> {
  const TripProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripHash();

  @$internal
  @override
  Trip create() => Trip();
}

String _$tripHash() => r'94ce0e4e34a67bef90728e5e61a239d7935dba4c';

abstract class _$Trip extends $AsyncNotifier<Set<Place>> {
  FutureOr<Set<Place>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Set<Place>>, Set<Place>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Set<Place>>, Set<Place>>,
        AsyncValue<Set<Place>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
