import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'screens/login_screen.dart';
import 'screens/todo_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos',
      debugShowCheckedModeBanner: false,
      theme: buildChocolateTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loggedInProvider).when(
          loading: () => const Scaffold(
            backgroundColor: appBg,
            body: Center(
              child: CircularProgressIndicator(color: choc700),
            ),
          ),
          error: (_, __) => const LoginScreen(),
          data: (loggedIn) =>
              loggedIn ? const TodoScreen() : const LoginScreen(),
        );
  }
}