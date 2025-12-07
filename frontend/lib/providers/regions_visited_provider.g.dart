// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regions_visited_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegionsVisited)
const regionsVisitedProvider = RegionsVisitedProvider._();

final class RegionsVisitedProvider
    extends $NotifierProvider<RegionsVisited, Set<Region>> {
  const RegionsVisitedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'regionsVisitedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$regionsVisitedHash();

  @$internal
  @override
  RegionsVisited create() => RegionsVisited();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<Region> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<Region>>(value),
    );
  }
}

String _$regionsVisitedHash() => r'624167d11ce7eae11109313be37900be28bfb3c8';

abstract class _$RegionsVisited extends $Notifier<Set<Region>> {
  Set<Region> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<Region>, Set<Region>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<Region>, Set<Region>>, Set<Region>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
