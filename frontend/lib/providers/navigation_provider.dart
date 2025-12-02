import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class Navigation extends _$Navigation {
  @override
  int build() {
    return 0; // Start at home screen
  }

  void setIndex(int index) {
    state = index;
  }
}
