import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jusel_app/data/models/app_user.dart';
import 'package:jusel_app/data/repositories/auth_repository.dart';
import 'package:jusel_app/core/providers/database_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    usersDao: ref.watch(usersDaoProvider),
  );
});

final initialUserExistsProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.hasExistingUsers();
});

class AuthViewModel extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AsyncValue.data(null)) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(user);
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> signUpFirstUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpUser(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
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
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpUser(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
        enforceFirstUser: false,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Riverpod provider for the AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AppUser?>>((ref) {
      final authRepo = ref.watch(authRepositoryProvider);
      return AuthViewModel(authRepo);
    });
