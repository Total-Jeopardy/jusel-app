import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsRefreshTriggerProvider = StateNotifierProvider<StateController<int>, int>((ref) {
  return StateController(0);
});

extension ProductsRefreshExtension on StateController<int> {
  void refresh() {
    state++;
  }
}

