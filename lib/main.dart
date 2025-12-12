import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/router/router.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/widgets/offline_indicator.dart';
import 'package:jusel_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // MUST come first

  await Firebase.initializeApp(
    // MUST run before runApp
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MainApp())); // App starts AFTER Firebase
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeState = ref.watch(themeProvider);
    
    // Initialize periodic sync service asynchronously after first frame
    // The provider will auto-start sync if user is already logged in
    // and will listen to auth changes to start/stop accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(periodicSyncServiceProvider);
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: juselLightTheme,
      darkTheme: juselDarkTheme,
      themeMode: themeState.mode == AppThemeMode.system
          ? ThemeMode.system
          : (themeState.mode == AppThemeMode.dark
                ? ThemeMode.dark
                : ThemeMode.light),
      builder: (context, child) {
        return OfflineIndicator(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
