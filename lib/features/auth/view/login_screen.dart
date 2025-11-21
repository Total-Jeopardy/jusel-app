import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/data/models/app_user.dart';

import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/dashboard/view/apprentice_dashboard.dart';
import 'package:jusel_app/features/dashboard/view/boss_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    ref.listen<AsyncValue<AppUser?>>(authViewModelProvider, (previous, next) {
      next.whenData((user) {
        if (user == null) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (user.role == "boss") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BossDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ApprenticeDashboard()),
            );
          }
        });
      });
    });
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),
              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  await ref
                      .read(authViewModelProvider.notifier)
                      .signIn(email, password);
                },
                child: const Text("Login"),
              ),

              const SizedBox(height: 16),

              // Loading
              if (authState.isLoading) const CircularProgressIndicator(),

              const SizedBox(height: 16),

              // Error message
              authState.hasError
                  ? Text(
                      authState.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
