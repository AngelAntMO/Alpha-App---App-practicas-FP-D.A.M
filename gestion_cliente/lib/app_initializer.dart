import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../notifications_service.dart';

//Inicialización de servicios

class AppInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationsService.init();
  }
}