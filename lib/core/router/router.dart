import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jusel_app/features/auth/view/login_screen.dart';
import 'package:jusel_app/features/auth/view/first_setup_screen.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/dashboard/view/apprentice_dashboard.dart';
import 'package:jusel_app/features/dashboard/view/boss_dashboard.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final refreshListenable =
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges());

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final loggingIn = state.matchedLocation == '/login';
      final firstSetup = state.matchedLocation == '/first-setup';

      if (user == null) {
        return firstSetup ? null : (loggingIn ? null : '/login');
      }

      if (firstSetup) {
        return user.role == 'boss'
            ? '/boss-dashboard'
            : '/apprentice-dashboard';
      }

      if (loggingIn) {
        return user.role == 'boss'
            ? '/boss-dashboard'
            : '/apprentice-dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/first-setup',
        builder: (context, state) => const FirstSetupScreen(),
      ),
      GoRoute(
        path: '/boss-dashboard',
        builder: (context, state) => const BossDashboard(),
      ),
      GoRoute(
        path: '/apprentice-dashboard',
        builder: (context, state) => const ApprenticeDashboard(),
      ),
    ],
  );
});

/// Helper to refresh GoRouter on auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
