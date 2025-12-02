// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Trip)
const tripProvider = TripProvider._();

final class TripProvider extends $NotifierProvider<Trip, Set<Place>> {
  const TripProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripHash();

  @$internal
  @override
  Trip create() => Trip();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<Place> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<Place>>(value),
    );
  }
}

String _$tripHash() => r'6bf9071211907965fc3143381a1ad167eb5c6690';

abstract class _$Trip extends $Notifier<Set<Place>> {
  Set<Place> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<Place>, Set<Place>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<Place>, Set<Place>>, Set<Place>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
