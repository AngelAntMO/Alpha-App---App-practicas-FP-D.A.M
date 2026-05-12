import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gestion_cliente/screens/login_screen.dart';
import 'package:gestion_cliente/screens/register_screen.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
import 'package:gestion_cliente/screens/admin_page.dart';
import 'package:gestion_cliente/screens/servicios/gimnasio_page.dart';
import 'package:gestion_cliente/screens/servicios/yoga_page.dart';
import 'package:gestion_cliente/screens/servicios/peluqueria_page.dart';
import 'package:gestion_cliente/screens/servicios/fisioterapia_page.dart';
import 'package:gestion_cliente/screens/servicios/academia_page.dart';
import 'package:gestion_cliente/notifications_service.dart';

void main() async {
  // Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationsService.init();
  //  Inicializa firebase con las opciones específicas para cada plataforma
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AlphaApp());
}

class AlphaApp extends StatelessWidget {
  const AlphaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AlphaApp',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.inicioTheme,
      home: const SplashScreen(),

      routes: {
        // Autenticación
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Dashboard
        '/dashboard': (context) => const DashboardPage(negocios: []),
        '/admin': (context) => const AdminPage(),

        // Servicios
        '/gimnasio': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          return GimnasioPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Gimnasio',
          );
        },
        '/yoga': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          return YogaPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Yoga',
          );
        },
        '/peluqueria': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return PeluqueriaPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Peluqueria',
          );
        },
        '/fisioterapia': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return FisioterapiaPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Fisioterapia',
          );
        },
        '/academia': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return AcademiaPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Academia',
          );
        },
      },
    );
  }
}
