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
    // Reemplazamos la lectura estática por un StreamBuilder que escucha el estado de autenticación en tiempo real
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Si el estado está cargando el inicio de Firebase
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authSnapshot.data;

        // Si no hay usuario logueado (o acaba de cerrar sesión), va directo al Login
        if (user == null) {
          return const LoginPage();
        }

        // Si hay un usuario, comprobamos su rol mediante el FutureBuilder original
        return FutureBuilder<Widget>(
          future: _getHome(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
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