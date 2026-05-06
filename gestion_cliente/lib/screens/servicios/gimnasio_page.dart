import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gestion_cliente/notifications_service.dart';

class GimnasioPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const GimnasioPage({
    super.key,
    required this.userId,
    required this.negocio,
  });

  @override
  State<GimnasioPage> createState() => _GimnasioPageState();
}

class _GimnasioPageState extends State<GimnasioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<DateTime, int> _reservasPorDia = {};

  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _actividadSeleccionada = '';
  bool _loading = false;

  final List<String> actividades = [
    'Sala Fitness',
    'Spinning',
    'Cross Training',
    'Boxeo',
    'Zumba',
  ];

  final List<String> horariosTotales = [
    '08:00',
    '10:00',
    '12:00',
    '16:00',
    '18:00',
    '20:00',
  ];

  static const int cupos = 15;
  static const int maxReservasUsuario = 6;

  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  DocumentReference claseRef(String nombre) =>
      _db.collection('clases').doc(nombre);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _horasDisponibles = List.from(horariosTotales);
    _fetchCalendarData();
  }

  DateTime _soloDia(DateTime d) => DateTime(d.year, d.month, d.day);

  // ─────────────────────────────
  // CALENDARIO
  // ─────────────────────────────
  Future<void> _fetchCalendarData() async {
    final snapshot = await _db
        .collection('reservas')
        .where('negocioRef', isEqualTo: negocioRef)
        .where('estado', isEqualTo: 'activa')
        .get();

    final Map<DateTime, int> map = {};

    for (var doc in snapshot.docs) {
      final fecha = (doc['fecha'] as Timestamp).toDate();
      final day = _soloDia(fecha);
      map[day] = (map[day] ?? 0) + 1;
    }

    setState(() => _reservasPorDia = map);
  }

  // ─────────────────────────────
  // HORAS DISPONIBLES
  // ─────────────────────────────
  Future<void> _actualizarHoras() async {
    if (_selectedDay == null || _actividadSeleccionada.isEmpty) return;

    setState(() => _loading = true);

    final dia = _soloDia(_selectedDay!);

    final snapshot = await _db
        .collection('reservas')
        .where('negocioRef', isEqualTo: negocioRef)
        .where('claseRef', isEqualTo: claseRef(_actividadSeleccionada))
        .where('fecha', isEqualTo: Timestamp.fromDate(dia))
        .where('estado', isEqualTo: 'activa')
        .get();

    Map<String, int> conteo = {};

    for (var doc in snapshot.docs) {
      final hora = doc['hora'];
      conteo[hora] = (conteo[hora] ?? 0) + 1;
    }

    setState(() {
      _horasDisponibles = horariosTotales.where((h) {
        return (conteo[h] ?? 0) < cupos;
      }).toList();

      if (!_horasDisponibles.contains(_horaSeleccionada)) {
        _horaSeleccionada = '';
      }

      _loading = false;
    });
  }

  // ─────────────────────────────
  // RESERVAR
  // ─────────────────────────────
  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _actividadSeleccionada.isEmpty) {
      _msg("Completa todos los campos");
      return;
    }

    final dia = _soloDia(_selectedDay!);
    final claseR = claseRef(_actividadSeleccionada);

    final partes = _horaSeleccionada.split(':');

    final fechaCompleta = DateTime(
      dia.year,
      dia.month,
      dia.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    setState(() => _loading = true);

    try {
      // 🔒 1. LIMITE USUARIO (SOLO GIMNASIO)
      final misReservas = await _db
          .collection('reservas')
          .where('userId', isEqualTo: widget.userId)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('estado', isEqualTo: 'activa')
          .get();

      if (misReservas.docs.length >= maxReservasUsuario) {
        _msg("Máximo $maxReservasUsuario reservas activas en gimnasio");
        return;
      }

      // 🔒 2. EVITAR DUPLICADO MISMA CLASE
      final duplicado = await _db
          .collection('reservas')
          .where('userId', isEqualTo: widget.userId)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('claseRef', isEqualTo: claseR)
          .where('fecha', isEqualTo: Timestamp.fromDate(dia))
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      if (duplicado.docs.isNotEmpty) {
        _msg("Ya tienes esta reserva");
        return;
      }

      // 🔒 3. CUPOS (15 por clase/hora)
      final snapshot = await _db
          .collection('reservas')
          .where('negocioRef', isEqualTo: negocioRef)
          .where('claseRef', isEqualTo: claseR)
          .where('fecha', isEqualTo: Timestamp.fromDate(dia))
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      if (snapshot.docs.length >= cupos) {
        _msg("Cupo completo");
        return;
      }

      // 💾 GUARDAR
      await _db.collection('reservas').add({
        'userId': widget.userId,
        'negocioRef': negocioRef,
        'claseRef': claseR,
        'negocioNombre': widget.negocio,
        'claseNombre': _actividadSeleccionada,
        'fecha': Timestamp.fromDate(dia),
        'hora': _horaSeleccionada,
        'fechaHora': Timestamp.fromDate(fechaCompleta),
        'estado': 'activa',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _msg("Reserva confirmada");

      await _fetchCalendarData();

      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _actividadSeleccionada = '';
        _horasDisponibles = List.from(horariosTotales);
      });

      await NotificationsService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        servicio: widget.negocio,
        especialista: _actividadSeleccionada,
        scheduledDate:
            fechaCompleta.subtract(const Duration(hours: 24)), // 🔥 24h antes
      );
    } catch (e) {
      _msg("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(
          widget.negocio,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), 
              Color(0xFFFFF176), 
              Color(0xFFFFC107), 
              Color(0xFFFFA000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    // LOGO
                    Image.asset(
                      'assets/images/LogoAlphaAppGimnasio.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    // CALENDARIO
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TableCalendar(
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final day = _soloDia(date);
                            final count = _reservasPorDia[day] ?? 0;

                            if (count == 0) return null;

                            Color color;

                            if (count >= cupos * horariosTotales.length) {
                              color = Colors.red; // 🔴 todo el día lleno
                            } else if (count >= (cupos * horariosTotales.length) / 2) {
                              color = Colors.orange; // 🟠 medio lleno
                            } else {
                              color = Colors.green; // 🟢 hay reservas
                            }

                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        locale: 'es_ES',
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                        onDaySelected: (s, f) {
                          setState(() {
                            _selectedDay = s;
                            _focusedDay = f;
                          });
                          _actualizarHoras();
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFFF9A825), // amarillo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFFBC02D),

                            shape: BoxShape.circle,
                          ),

                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ACTIVIDAD
                    _buildDropdown(
                      label: "Actividad",
                      value: _actividadSeleccionada,
                      items: actividades,
                      onChanged: (v) {
                        setState(() => _actividadSeleccionada = v!);
                        _actualizarHoras();
                      },
                    ),

                    const SizedBox(height: 15),

                    // HORA
                    _buildDropdown(
                      label: "Hora disponible",
                      value: _horaSeleccionada,
                      items: _horasDisponibles,
                      onChanged: _selectedDay == null
                          ? null
                          : (v) => setState(() => _horaSeleccionada = v!),
                    ),

                    const SizedBox(height: 35),

                    // BOTÓN
                    SizedBox(
                      width: screenWidth * 0.7,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _reservar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                                Color(0xFF64B5F6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "RESERVAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value.isEmpty ? null : value,
        decoration: const InputDecoration(
          labelText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        hint: Text(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
