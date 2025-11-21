import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jusel_app/data/models/app_user.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  String? getCurrentUserId() {
    final user = auth.currentUser;
    return user?.uid;
  }

  Future<AppUser?> fetchUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    print("USER DATA: ${doc.data()}");
    if (!doc.exists) {
      return null;
    }
    final data = doc.data()!;

    return AppUser.fromJson(data);
  }

  Future<void> createUserInFirestore(AppUser user) async {
    await firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<AppUser?> signIn(String email, String password) async {
    try {
      // 1. Firebase login
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // 2. Get UID
      final uid = auth.currentUser?.uid;
      if (uid == null) return null;

      // 3. Load Firestore profile
      final user = await fetchUserFromFirestore(uid);

      return user;
    } on FirebaseAuthException catch (e) {
      throw e; // Let ViewModel handle the UI error message
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
