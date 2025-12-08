// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geocodeService)
const geocodeServiceProvider = GeocodeServiceProvider._();

final class GeocodeServiceProvider
    extends $FunctionalProvider<GeocodeService, GeocodeService, GeocodeService>
    with $Provider<GeocodeService> {
  const GeocodeServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'geocodeServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$geocodeServiceHash();

  @$internal
  @override
  $ProviderElement<GeocodeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeocodeService create(Ref ref) {
    return geocodeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodeService>(value),
    );
  }
}

String _$geocodeServiceHash() => r'f8956d763feabf82c457bc9b77f5259b068cba0c';
