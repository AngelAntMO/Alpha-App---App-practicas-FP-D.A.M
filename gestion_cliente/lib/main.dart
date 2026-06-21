import 'package:flutter/material.dart';
import 'app.dart';
import 'app_initializer.dart';

// Arranque de la App

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  runApp(const AlphaApp());
}