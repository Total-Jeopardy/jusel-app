import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import 'package:jusel_app/data/models/app_user.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/users_dao.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final UsersDao usersDao;

  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.usersDao,
  });

  Future<AppUser?> signIn(String email, String password) async {
    try {
      // 1. Firebase login
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // 2. Get UID
      final uid = auth.currentUser?.uid;
      if (uid == null) return null;

      // 3. Try loading locally first (offline mode)
      final localUser = await usersDao.getUserById(uid);
      if (localUser != null) {
        print("Loaded user offline");

        return AppUser(
          uid: localUser.id,
          name: localUser.name,
          phone: localUser.phone,
          email: localUser.email,
          role: localUser.role,
          bossId: localUser.bossId,
          isActive: localUser.isActive,
          createdAt: localUser.createdAt,
          updatedAt: localUser.updatedAt,
        );
      }

      // 4. Load Firestore profile (online mode)
      final user = await _fetchUserFromFirestore(uid);
      if (user == null) return null;

      // 5. Save to Drift
      await usersDao.insertUser(
        UsersTableCompanion(
          id: Value(user.uid),
          name: Value(user.name),
          phone: Value(user.phone),
          email: Value(user.email),
          role: Value(user.role),
          bossId: Value(user.bossId),
          isActive: Value(user.isActive),
          createdAt: Value(user.createdAt),
          updatedAt: user.updatedAt == null
              ? const Value.absent()
              : Value(user.updatedAt!),
        ),
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  /// When app starts and Firebase already has a session, hydrate local state.
  Future<AppUser?> getCurrentUser() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;

    final localUser = await usersDao.getUserById(uid);
    if (localUser != null) {
      return AppUser(
        uid: localUser.id,
        name: localUser.name,
        phone: localUser.phone,
        email: localUser.email,
        role: localUser.role,
        bossId: localUser.bossId,
        isActive: localUser.isActive,
        createdAt: localUser.createdAt,
        updatedAt: localUser.updatedAt,
      );
    }

    final user = await _fetchUserFromFirestore(uid);
    if (user == null) return null;

    await usersDao.insertUser(
      UsersTableCompanion(
        id: Value(user.uid),
        name: Value(user.name),
        phone: Value(user.phone),
        email: Value(user.email),
        role: Value(user.role),
        bossId: Value(user.bossId),
        isActive: Value(user.isActive),
        createdAt: Value(user.createdAt),
        updatedAt:
            user.updatedAt == null ? const Value.absent() : Value(user.updatedAt!),
      ),
    );

    return user;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Reset a user's password by email (sends reset link).
  /// For admin-driven resets, replace with a secure backend/Cloud Function.
  Future<void> resetUserPassword({
    required String email,
    String? newPassword, // retained for future backend-based direct reset
  }) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  /// Create a user. If [enforceFirstUser] is true, it only allows creation
  /// when no users exist yet (first-time setup).
  Future<AppUser> signUpUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role, // boss or apprentice
    String? bossId,
    bool enforceFirstUser = false,
  }) async {
    if (enforceFirstUser) {
      final exists = await hasExistingUsers();
      if (exists) {
        throw Exception('An account already exists. Please sign in instead.');
      }
    }

    if (bossId == null && role != 'boss') {
      throw Exception('Only bosses can sign up directly.');
    }
    if (bossId != null && role != 'apprentice') {
      throw Exception('Apprentices must be created by a boss.');
    }

    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user?.uid;
    if (uid == null) {
      throw Exception('Failed to create user.');
    }

    final now = DateTime.now();
    final user = AppUser(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      role: role,
      bossId: bossId,
      isActive: true,
      createdAt: now,
      updatedAt: null,
    );

    await firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'bossId': bossId,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': null,
    });

    await usersDao.insertUser(
      UsersTableCompanion.insert(
        id: uid,
        name: name,
        phone: phone,
        email: email,
        role: role,
        bossId: Value(bossId),
        isActive: const Value(true),
        createdAt: now,
      ),
    );

    return user;
  }

  Future<AppUser> signUpApprentice({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String bossId,
  }) {
    return signUpUser(
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: 'apprentice',
      bossId: bossId,
    );
  }

  /// Update user profile (name, phone, profileImageUrl)
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    final now = DateTime.now();
    final updateData = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(now),
    };

    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

    // Update Firestore
    await firestore.collection('users').doc(uid).update(updateData);

    // Update local database
    final existingUser = await usersDao.getUserById(uid);
    if (existingUser != null) {
      await usersDao.updateUser(
        UsersTableCompanion(
          id: Value(uid),
          name: name != null ? Value(name) : Value(existingUser.name),
          phone: phone != null ? Value(phone) : Value(existingUser.phone),
          email: Value(existingUser.email),
          role: Value(existingUser.role),
          bossId: Value(existingUser.bossId),
          isActive: Value(existingUser.isActive),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Returns true if any user exists (Firestore preferred, local fallback).
  Future<bool> hasExistingUsers() async {
    try {
      final snap = await firestore.collection('users').limit(1).get();
      if (snap.docs.isNotEmpty) return true;
    } catch (_) {
      // ignore and fallback to local
    }

    final count = await usersDao.getUserCount();
    return count > 0;
  }

  Future<AppUser?> _fetchUserFromFirestore(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return AppUser.fromJson({'uid': uid, ...data});
    } catch (e) {
      print("Error fetching user from Firestore: $e");
      return null;
    }
  }
}
