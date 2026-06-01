import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/inicio_superadmin.dart';
import 'package:gestion_cliente/screens/inicio_admin.dart';
import 'login_screen.dart';
import 'inicio_screen.dart';
import 'inicio_worker.dart'; 

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  Future<Widget> _getHome(User user) async {
  try {
    final uid = user.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return const LoginPage();
    }

    final data = doc.data();

    if (data == null) {
      return const LoginPage();
    }

    final role = (data['rol'] ?? 'usuario')
        .toString()
        .trim()
        .toLowerCase();

    switch (role) {
      case 'worker':
        return const InicioWorker();

      case 'admin':
        return const InicioAdmin();

      case 'superadmin':
        return const InicioSuperAdmin();

      default:
        return const PaginaInicio();
    }
  } catch (e) {
    debugPrint("Error obteniendo rol: $e");
    return const LoginPage();
  }
}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
  
        // Si no esta logueado, mostrar login
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // Comprobar el rol de firebase
        return FutureBuilder<Widget>(
          future: _getHome(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!roleSnapshot.hasData) {
              return const LoginPage();
            }

            return roleSnapshot.data!;
          },
        );
      },
    );
  }
}