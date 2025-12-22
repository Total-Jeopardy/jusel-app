import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jusel_app/data/models/app_user.dart';
import 'package:jusel_app/data/repositories/auth_repository.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/features/products/providers/products_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    usersDao: ref.watch(usersDaoProvider),
  );
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AppUser?>>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider), ref);
});

final initialUserExistsProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.hasExistingUsers();
});

class AuthViewModel extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthViewModel(this._authRepository, this._ref) : super(const AsyncValue.data(null)) {
    // Hydrate asynchronously after first frame to avoid blocking startup
    Future.microtask(() => _hydrate());
  }

  Future<void> _hydrate() async {
    try {
      // Add a small delay to ensure app has rendered first frame
      await Future.delayed(const Duration(milliseconds: 100));
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(user);
        // Hydrate profile image from Firestore on app start
        await _hydrateProfileImageFromFirestore(user.uid);
      }
    } catch (_) {
      // Ignore hydration errors; user will sign in again.
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signIn(email, password);

      if (user == null) {
        state = AsyncValue.error("No user profile found", StackTrace.current);
        return;
      }
      state = AsyncValue.data(user);

      // Hydrate profile image from Firestore to SettingsService
      await _hydrateProfileImageFromFirestore(user.uid);

      // Ensure apprentices always have auto sync enabled
      if (user.role == 'apprentice') {
        try {
          final settingsService = await _ref.read(settingsServiceProvider.future);
          await settingsService.setAutoSync(true);
        } catch (_) {
          // Ignore errors
        }
      }

      // Periodic sync service will auto-start via auth state listener
      // No need to manually restart here

      // Trigger downsync if online (run in background)
      _triggerBackgroundSync(user.uid);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Hydrates profile image URL from Firestore to SettingsService
  Future<void> _hydrateProfileImageFromFirestore(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;
      
      final data = doc.data();
      if (data == null) return;
      
      final profileImageUrl = data['profileImageUrl'] as String?;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        final settingsService = await _ref.read(settingsServiceProvider.future);
        await settingsService.setProfileImageUrl(profileImageUrl);
      }
    } catch (e) {
      // Ignore errors - profile image is optional
      print('Failed to hydrate profile image: $e');
    }
  }

  Future<void> signOut() async {
    // Clear profile image from SettingsService before signing out
    try {
      final settingsService = await _ref.read(settingsServiceProvider.future);
      await settingsService.setProfileImageUrl(null);
    } catch (_) {
      // Ignore errors - clearing is best effort
    }
    
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
    // Cancel any pending background sync
    _cancelBackgroundSync();
  }

  bool _backgroundSyncCancelled = false;

  void _cancelBackgroundSync() {
    _backgroundSyncCancelled = true;
  }

  Future<void> _triggerBackgroundSync(String userId) async {
    _backgroundSyncCancelled = false;
    
    try {
      final syncOrchestrator = _ref.read(syncOrchestratorProvider);
      
      // Check if still signed in
      if (_backgroundSyncCancelled || state.valueOrNull == null) {
        return;
      }

      if (!await syncOrchestrator.isOnline()) {
        // Log offline status but don't show error to user
        print('Background sync skipped: device is offline');
        return;
      }

      // Check again before starting sync
      if (_backgroundSyncCancelled || state.valueOrNull == null) {
        return;
      }

      // Run pull in background
      final pullResult = await syncOrchestrator.pullAllForUser(userId);
      
      // Check if user is still signed in before updating timestamp
      if (_backgroundSyncCancelled || state.valueOrNull == null) {
        print('Background sync cancelled: user signed out');
        return;
      }

      // Only update timestamp if pull succeeded and user is still signed in
      if (pullResult.status != SyncStatus.error &&
          pullResult.status != SyncStatus.offline &&
          pullResult.syncedCount > 0) {
        try {
          final settingsService = await _ref.read(settingsServiceProvider.future);
          // Final check before updating
          if (!_backgroundSyncCancelled && state.valueOrNull != null) {
            await settingsService.setLastSyncedAt(DateTime.now());
            print('Background sync completed: ${pullResult.syncedCount} items synced');
            
            // Trigger refresh of products and other data screens
            _ref.invalidate(productsRefreshTriggerProvider);
          }
        } catch (e) {
          print('Error updating last synced timestamp: $e');
        }
      } else if (pullResult.failedCount > 0) {
        print('Background sync had failures: ${pullResult.failedCount} items failed');
      }
    } catch (e, stackTrace) {
      // Log error but don't show to user (background operation)
      print('Background sync error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> signUpFirstUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpUser(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: 'boss',
        enforceFirstUser: true,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpAdditionalUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpUser(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: 'boss',
        enforceFirstUser: false,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createApprentice({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final current = state.valueOrNull;
    if (current == null || current.role != 'boss') {
      state = AsyncValue.error(
        'Only bosses can create apprentices',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpApprentice(
        name: name,
        phone: phone,
        email: email,
        password: password,
        bossId: current.uid,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
