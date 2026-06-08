import 'package:flutter/material.dart';

import 'auth_wrapper.dart';
import 'app_routes.dart';
import 'core/app_themes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

//Configuración de MaterialApp

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

      home: const AuthWrapper(),

      routes: AppRoutes.routes,
    );
  }
}