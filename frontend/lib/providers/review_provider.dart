import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:virtour_frontend/frontend_service_layer/review_service.dart';
import 'package:virtour_frontend/providers/user_info_provider.dart';

part 'review_provider.g.dart';

@Riverpod(keepAlive: true)
ReviewService reviewService(Ref ref) {
  final user = ref.watch(userSessionProvider);

  final String token = user?.userSessionToken ?? '';

  return ReviewService(token: token, ref: ref);
}