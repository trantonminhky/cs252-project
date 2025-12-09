// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserSession)
const userSessionProvider = UserSessionProvider._();

final class UserSessionProvider
    extends $NotifierProvider<UserSession, UserInfo?> {
  const UserSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSessionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSessionHash();

  @$internal
  @override
  UserSession create() => UserSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserInfo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserInfo?>(value),
    );
  }
}

String _$userSessionHash() => r'eaaf80da49208428bb08fc018eeaf2f070c9d1ca';

abstract class _$UserSession extends $Notifier<UserInfo?> {
  UserInfo? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserInfo?, UserInfo?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserInfo?, UserInfo?>, UserInfo?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
