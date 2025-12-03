// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_place_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedPlace)
const selectedPlaceProvider = SelectedPlaceProvider._();

final class SelectedPlaceProvider
    extends $NotifierProvider<SelectedPlace, Place?> {
  const SelectedPlaceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedPlaceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedPlaceHash();

  @$internal
  @override
  SelectedPlace create() => SelectedPlace();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Place? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Place?>(value),
    );
  }
}

String _$selectedPlaceHash() => r'096ee2c2f1cfc3d3e3130b9aab31f04a7d96d60b';

abstract class _$SelectedPlace extends $Notifier<Place?> {
  Place? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Place?, Place?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Place?, Place?>, Place?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
