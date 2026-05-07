import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importaciones de tus pantallas
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart'; // Asumo que es PaginaInicio
import 'package:gestion_cliente/screens/splash_screen.dart';
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

// Asegúrate de que esta variable esté definida si la usas para notificaciones
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de servicios
  await NotificationsService.init();
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
      
      // 1. EL TEMA: Forzamos el color oscuro de fondo para evitar el flash blanco
      theme: AppThemes.inicioTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E293B),
      ),
      
      // 2. EL HOME: Ahora el AuthWrapper decide qué pantalla mostrar
      home: const AuthWrapper(),

      routes: {
        //Atenticación
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        //Dashboard y Admin
        '/dashboard': (context) => DashboardPage(negocios: []),
        '/admin': (context) => const AdminPage(),
        
        //Servicios
        '/gimnasio': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return GimnasioPage(userId: args?['userId'] ?? '', negocio: args?['negocio'] ?? 'Gimnasio');
        },
        '/yoga': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return YogaPage(userId: args?['userId'] ?? '', negocio: args?['negocio'] ?? 'Yoga');
        },
        '/peluqueria': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PeluqueriaPage(userId: args?['userId'] ?? '', negocio: args?['negocio'] ?? 'Peluqueria');
        },
        '/fisioterapia': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return FisioterapiaPage(userId: args?['userId'] ?? '', negocio: args?['negocio'] ?? 'Fisioterapia');
        },
        '/academia': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return AcademiaPage(userId: args?['userId'] ?? '', negocio: args?['negocio'] ?? 'Academia');
        },
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // MIENTRAS CARGA FIREBASE: Mostramos un fondo oscuro (adiós flash blanco)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E293B),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64B5F6),
              ),
            ),
          );
        }

        // CASO A: USUARIO LOGUEADO
        // Entra directamente a la App sin pasar por el Splash de 3 segundos.
        if (snapshot.hasData) {
          return const PaginaInicio(); 
        }

        // CASO B: USUARIO NO LOGUEADO
        // Mostramos tu SplashScreen animado antes de que vaya al Login.
        return const SplashScreen();
      },
    );
  }
}