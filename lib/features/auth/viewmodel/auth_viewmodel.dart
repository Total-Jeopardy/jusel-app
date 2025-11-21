import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jusel_app/data/models/app_user.dart';
import 'package:jusel_app/data/repositories/auth_repository.dart';

class AuthViewModel extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AsyncValue.data(null));

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
}

/// Riverpod provider for the AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AppUser?>>((ref) {
      final authRepo = AuthRepository(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );

      return AuthViewModel(authRepo);
    });
