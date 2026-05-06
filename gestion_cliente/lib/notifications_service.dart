import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

// Navigator global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Config por servicio
const _servicioConfig = {
  'Fisioterapia': _ServicioConfig('🦴', 'ic_notif_fisioterapia', 'fisioterapia'),
  'Gimnasio':     _ServicioConfig('💪', 'ic_notif_gimnasio', 'gimnasio'),
  'Yoga':         _ServicioConfig('🧘', 'ic_notif_yoga', 'yoga'),
  'Peluqueria':   _ServicioConfig('✂️', 'ic_notif_peluqueria', 'peluqueria'),
  'Academia':     _ServicioConfig('📚', 'ic_notif_academia', 'academia'),
};

class _ServicioConfig {
  final String emoji;
  final String icono;
  final String ruta;

  const _ServicioConfig(this.emoji, this.icono, this.ruta);
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// INIT
  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _onTap(details.payload);
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// CLICK NOTIFICATION
  static void _onTap(String? payload) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/dashboard',
      (route) => false,
    );
  }

  /// MAIN FUNCTION (RESERVAS)
  static Future<void> scheduleNotification({
    required int id,
    required String servicio,
    required String especialista,
    required DateTime scheduledDate,
    bool dobleRecordatorio = true,
  }) async {
    if (!_initialized) await init();

    final config = _servicioConfig[servicio] ??
        const _ServicioConfig('📅', '@mipmap/ic_launcher', 'dashboard');

    // 🔔 NOTIFICACIÓN 24H ANTES
    final notify24h = scheduledDate.subtract(const Duration(hours: 24));

    // 🔔 NOTIFICACIÓN 1H ANTES
    final notify1h = scheduledDate.subtract(const Duration(hours: 1));

    final notifications = <DateTime>[];

    if (dobleRecordatorio) {
      notifications.addAll([notify24h, notify1h]);
    } else {
      notifications.add(notify1h);
    }

    int localId = id;

    for (final notifyAt in notifications) {
      if (notifyAt.isBefore(DateTime.now())) continue;

      await _schedule(
        id: localId++,
        config: config,
        servicio: servicio,
        especialista: especialista,
        scheduledDate: scheduledDate,
        notifyAt: notifyAt,
      );
    }
  }

  /// INTERNAL SCHEDULER
  static Future<void> _schedule({
    required int id,
    required _ServicioConfig config,
    required String servicio,
    required String especialista,
    required DateTime scheduledDate,
    required DateTime notifyAt,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reservas_channel',
      'Recordatorio de citas',
      channelDescription: 'Notificaciones de reservas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final formattedHora =
        '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';

    final is24h = scheduledDate.difference(notifyAt).inHours > 2;

    final title = is24h
        ? '${config.emoji} Recordatorio (mañana)'
        : '${config.emoji} Recordatorio (hoy)';

    final body = is24h
        ? '🗓️ Mañana tienes una sesión de $servicio\n👤 $especialista\n🕐 $formattedHora\n\n💙 ¡Prepárate!'
        : '⏰ Tu cita empieza pronto\n📍 $servicio\n👤 $especialista\n🕐 $formattedHora\n\n💙 ¡Te esperamos!';

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(notifyAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: config.ruta,
      );
    } catch (_) {
      // fallback
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(notifyAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: config.ruta,
      );
    }
  }

  /// CANCELAR UNA NOTIFICACIÓN
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// CANCELAR TODAS
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
