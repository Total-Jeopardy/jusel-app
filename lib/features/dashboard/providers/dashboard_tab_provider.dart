import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the currently selected tab on the dashboard.
class DashboardTabNotifier extends StateNotifier<int> {
  DashboardTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }

  void goToDashboard() {
    state = 0;
  }
}

final dashboardTabProvider =
    StateNotifierProvider<DashboardTabNotifier, int>((ref) {
  return DashboardTabNotifier();
});
