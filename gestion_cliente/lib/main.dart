import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/splash_screen.dart';
import 'package:gestion_cliente/screens/login_screen.dart';
import 'package:gestion_cliente/screens/register_screen.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
import 'package:gestion_cliente/screens/inicio_admin.dart';
import 'package:gestion_cliente/screens/servicios/gimnasio_page.dart';
import 'package:gestion_cliente/screens/servicios/yoga_page.dart';
import 'package:gestion_cliente/screens/servicios/peluqueria_page.dart';
import 'package:gestion_cliente/screens/servicios/fisioterapia_page.dart';
import 'package:gestion_cliente/screens/servicios/academia_page.dart';
import 'package:gestion_cliente/notifications_service.dart';
import 'package:gestion_cliente/screens/root_page.dart';

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
      
      
      theme: AppThemes.inicioTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E293B),
      ),
      
      //  El AuthWrapper decide qué pantalla mostrar
      home: const AuthWrapper(),

      routes: {
        //Atenticación
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        //Dashboard y Admin
        '/dashboard': (context) => DashboardPage(negocios: []),
        '/admin': (context) => const InicioAdmin(),
        
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

        // Mientras dura el splash
        if (splashSnapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        // Después del splash escucha auth
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