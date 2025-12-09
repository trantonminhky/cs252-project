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

String _$tripHash() => r'2b4579c6161147f2b33406000b244e2c83ce9d10';

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
