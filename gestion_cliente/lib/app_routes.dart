import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_page.dart';
import '../screens/inicio_admin.dart';

//Definición de rutas para la navegación

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (_) => const LoginPage(),
    '/register': (_) => const RegisterPage(),
    '/dashboard': (_) => DashboardPage(negocios: const []),
    '/admin': (_) => const InicioAdmin(),
  };
}