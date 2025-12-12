import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/frontend_service_layer/geocode_service.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';

part 'geocode_provider.g.dart';

@Riverpod(keepAlive: true)
GeocodeService geocodeService(Ref ref) {
  final user = ref.watch(userSessionProvider);

  final String token = user?.userSessionToken ?? '';

  return GeocodeService(token: token, ref: ref);
}