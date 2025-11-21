import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/features/auth/view/login_screen.dart';
import 'package:jusel_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // MUST come first

  await Firebase.initializeApp(
    // MUST run before runApp
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: const MainApp())); // App starts AFTER Firebase
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
