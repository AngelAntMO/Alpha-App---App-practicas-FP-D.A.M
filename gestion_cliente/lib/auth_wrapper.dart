
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/root_page.dart';
import '../screens/splash_screen.dart';

// Control de autenticación

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _startup;

  @override
  void initState() {
    super.initState();

    _startup = Future.delayed(
      const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startup,
      builder: (context, splashSnapshot) {
        if (splashSnapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!authSnapshot.hasData) {
              return const LoginPage();
            }

            return const RootPage();
          },
        );
      },
    );
  }
}