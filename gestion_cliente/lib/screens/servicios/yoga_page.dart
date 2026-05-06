import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gestion_cliente/notifications_service.dart';

const _kColeccion = 'reservas';
const _kEstadoActiva = 'activa';
const _kCampoFecha = 'fecha';
const _kCampoHora = 'hora';
const _kCampoEstado = 'estado';
const _kCampoUserId = 'userId';
const _kCampoNegocioRef = 'negocioRef';
const _kCampoClase = 'claseNombre';
const _kMaxPorHora = 10;

class YogaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const YogaPage({super.key, required this.userId, required this.negocio});

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _blockedDays = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _claseSeleccionada = '';
  bool _loading = false;

  final List<String> clases = [
    'Yoga Suave',
    'Vinyasa',
    'Power Yoga',
    'Meditación',
  ];

  final List<String> horariosTotales = ['08:00', '10:00', '18:00', '20:00'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _fetchBlockedDays() async {
    try {
      final snapshot = await _db
          .collection(_kColeccion)
          .where(_kCampoNegocioRef, isEqualTo: negocioRef)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      final Set<DateTime> blocked = {};

      for (var doc in snapshot.docs) {
        final fecha = (doc[_kCampoFecha] as Timestamp).toDate();
        blocked.add(DateTime(fecha.year, fecha.month, fecha.day));
      }

      if (mounted) {
        setState(() {
          _blockedDays = blocked.toList();
        });
      }
    } catch (e) {
      debugPrint("Error bloqueando días: $e");
    }
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) return;

    setState(() => _loading = true);

    try {
      final fechaBusqueda = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      final snapshot = await _db
          .collection(_kColeccion)
          .where(_kCampoNegocioRef, isEqualTo: negocioRef)
          .where(_kCampoFecha, isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where(_kCampoClase, isEqualTo: _claseSeleccionada)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      final Map<String, int> conteo = {};
      final Set<String> mias = {};

      for (var doc in snapshot.docs) {
        final hora = doc[_kCampoHora] as String;
        final uid = doc[_kCampoUserId] as String;

        conteo[hora] = (conteo[hora] ?? 0) + 1;

        if (uid == widget.userId) {
          mias.add(hora);
        }
      }

      setState(() {
        _horasDisponibles = horariosTotales.where((h) {
          final total = conteo[h] ?? 0;
          final yaReservado = mias.contains(h);
          return total < _kMaxPorHora && !yaReservado;
        }).toList();

        if (!_horasDisponibles.contains(_horaSeleccionada)) {
          _horaSeleccionada = '';
        }
      });
    } catch (e) {
      debugPrint("Error horas: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _claseSeleccionada.isEmpty) {
      _mensaje("Completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    try {
      DateTime fechaBusqueda = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      final check = await FirebaseFirestore.instance
          .collection(_kColeccion)
          .where(_kCampoNegocioRef, isEqualTo: negocioRef)
          .where(_kCampoFecha, isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where(_kCampoClase, isEqualTo: _claseSeleccionada)
          .where(_kCampoHora, isEqualTo: _horaSeleccionada)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      bool yaExiste = check.docs.any((d) => d[_kCampoUserId] == widget.userId);

      if (yaExiste) {
        _mensaje("Ya tienes una reserva en esta clase");
        setState(() => _loading = false);
        return;
      }

      if (check.docs.length >= 10) {
        _mensaje("Cupo lleno");
        setState(() => _loading = false);
        return;
      }

      final partesHora = _horaSeleccionada.split(':');
      final fechaCompleta = DateTime(
        fechaBusqueda.year,
        fechaBusqueda.month,
        fechaBusqueda.day,
        int.parse(partesHora[0]),
        int.parse(partesHora[1]),
      );

      await FirebaseFirestore.instance.collection(_kColeccion).add({
        _kCampoUserId: widget.userId,

        _kCampoNegocioRef: FirebaseFirestore.instance
            .collection('negocios')
            .doc(widget.negocio),

        'negocioNombre': widget.negocio,

        _kCampoClase: _claseSeleccionada,

        'claseRef': FirebaseFirestore.instance
            .collection('clases')
            .doc(_claseSeleccionada),

        _kCampoFecha: fechaBusqueda,
        _kCampoHora: _horaSeleccionada,

        'fechaHora': Timestamp.fromDate(fechaCompleta),

        _kCampoEstado: _kEstadoActiva,

        'timestamp': FieldValue.serverTimestamp(),
      });

      _mensaje("Reserva confirmada");

      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _claseSeleccionada = '';
        _horasDisponibles = List.from(horariosTotales);
      });

      _fetchBlockedDays();

      try {
        await NotificationsService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          servicio: widget.negocio,
          especialista: _claseSeleccionada,
          scheduledDate: fechaCompleta,
        );
      } catch (e) {
        debugPrint('Error al programar notificación: $e');
      }
    } catch (e) {
      _mensaje("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(
          widget.negocio,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF14B8A6), Color(0xFF0F766E)],
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
                    Image.asset(
                      'assets/images/LogoAlphaAppYoga.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        locale: 'es_ES',
                        startingDayOfWeek: StartingDayOfWeek.monday,

                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '',
                        },

                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),

                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                          _actualizarHorasDisponibles();
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 184, 197),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF14B8A6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (_blockedDays.any((d) => isSameDay(d, date))) {
                              return Positioned(
                                bottom: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _claseSeleccionada.isEmpty
                            ? null
                            : _claseSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Yoga',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: clases
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => _claseSeleccionada = val!);
                          _actualizarHorasDisponibles();
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _horaSeleccionada.isEmpty
                            ? null
                            : _horaSeleccionada,

                        decoration: const InputDecoration(
                          labelText: 'Hora disponible',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _horasDisponibles
                            .map(
                              (h) => DropdownMenuItem(value: h, child: Text(h)),
                            )
                            .toList(),
                        onChanged: _selectedDay == null
                            ? null
                            : (val) => setState(() => _horaSeleccionada = val!),
                      ),
                    ),

                    const SizedBox(height: 35),

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
}
