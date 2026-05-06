import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gestion_cliente/notifications_service.dart';

// ─── Constantes ───────────────────────────────────────────────────────────────
const _kColeccion = 'reservas';
const _kEstadoActiva = 'activa';
const _kCampoFecha = 'fecha';
const _kCampoHora = 'hora';
const _kCampoEstado = 'estado';
const _kCampoUserId = 'userId';

const _kMaxReservas = 5;
const _kMaxSlotsPorDia = 8;

const _kEspecialistasSabado = ['Especialista 4', 'Especialista 5'];

// ─── Widget principal ──────────────────────────────────────────────────────────
class FisioterapiaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const FisioterapiaPage({
    super.key,
    required this.userId,
    required this.negocio,
  });

  @override
  State<FisioterapiaPage> createState() => _FisioterapiaPageState();
}

class _FisioterapiaPageState extends State<FisioterapiaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, int> _reservasPorDia = {};
  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _especialistaSeleccionado = '';
  bool _loading = false;

  final List<String> especialistas = [
    'Especialista 1',
    'Especialista 2',
    'Especialista 3',
    'Especialista 4',
    'Especialista 5',
  ];

  final List<String> horariosTotales = [
    '09:30','10:30','11:30','12:30','13:30','16:30','17:30','18:30',
  ];

  final List<String> horariosSabado = [
    '09:30','10:30','11:30','12:30','13:30',
  ];

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // 🔗 REFERENCIAS
  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  DocumentReference claseRef(String claseId) =>
      _db.collection('clases').doc(claseId);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
    _horasDisponibles = List.from(horariosTotales);
  }

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  List<String> get _especialistasFiltrados {
    if (_selectedDay == null) return [];
    return _selectedDay!.weekday == DateTime.saturday
        ? ['Especialista 4', 'Especialista 5']
        : ['Especialista 1', 'Especialista 2', 'Especialista 3'];
  }

  // ─── FIRESTORE ──────────────────────────────────────────────────────────────

  Future<void> _fetchBlockedDays() async {
    try {
      final snapshot = await _db
          .collection(_kColeccion)
          .where('negocioRef', isEqualTo: negocioRef)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      final Map<DateTime, int> contador = {};
      for (var doc in snapshot.docs) {
        final fecha = (doc[_kCampoFecha] as Timestamp).toDate();
        final day = _soloFecha(fecha);
        contador[day] = (contador[day] ?? 0) + 1;
      }

      if (mounted) {
        setState(() => _reservasPorDia = contador);
      }
    } catch (e) {
      _mostrar('Error al cargar el calendario.');
    }
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _especialistaSeleccionado.isEmpty) return;

    final esSabado = _selectedDay!.weekday == DateTime.saturday;

    if (esSabado && !_kEspecialistasSabado.contains(_especialistaSeleccionado)) {
      setState(() {
        _horasDisponibles = [];
        _horaSeleccionada = '';
      });
      _mostrar('Los sábados solo trabajan Especialista 4 y 5');
      return;
    }

    setState(() => _loading = true);

    try {
      final fecha = _soloFecha(_selectedDay!);

      final snapshot = await _db
          .collection(_kColeccion)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('claseRef', isEqualTo: claseRef(_especialistaSeleccionado))
          .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      final ocupadas = snapshot.docs.map((e) => e[_kCampoHora] as String).toSet();

      final base = esSabado ? horariosSabado : horariosTotales;

      final disponibles = base.where((h) => !ocupadas.contains(h)).toList();

      setState(() {
        _horasDisponibles = disponibles;
        if (!_horasDisponibles.contains(_horaSeleccionada)) {
          _horaSeleccionada = '';
        }
      });
    } catch (e) {
      _mostrar('Error al cargar horarios');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _especialistaSeleccionado.isEmpty) {
      _mostrar('Completa todos los campos');
      return;
    }

    final diaReserva = _soloFecha(_selectedDay!);
    final horaReserva = _horaSeleccionada;

    final claseReferencia = claseRef(_especialistaSeleccionado);

    final partesHora = horaReserva.split(':');

    final fechaCompleta = DateTime(
      diaReserva.year,
      diaReserva.month,
      diaReserva.day,
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );

    setState(() => _loading = true);

    try {
      // VALIDACIONES
     final misReservas = await _db
        .collection(_kColeccion)
        .where(_kCampoUserId, isEqualTo: widget.userId)
        .where('negocioRef', isEqualTo: negocioRef)
        .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
        .get();

      if (misReservas.docs.length >= _kMaxReservas) {
        throw Exception('Máximo $_kMaxReservas reservas activas');
      }

      final check = await _db
          .collection(_kColeccion)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('claseRef', isEqualTo: claseReferencia)
          .where('fecha', isEqualTo: Timestamp.fromDate(diaReserva))
          .where('hora', isEqualTo: horaReserva)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      if (check.docs.isNotEmpty) {
        throw Exception('Hora ocupada');
      }

      // GUARDAR
      final docRef = _db.collection(_kColeccion).doc();

      await docRef.set({
        'userId': widget.userId,
        'negocioRef': negocioRef,
        'claseRef': claseReferencia,
        'negocioNombre': widget.negocio,
        'claseNombre': _especialistaSeleccionado,
        'fecha': Timestamp.fromDate(diaReserva),
        'hora': horaReserva,
        'fechaHora': Timestamp.fromDate(fechaCompleta),
        'estado': _kEstadoActiva,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _mostrar('Reserva confirmada');

      _fetchBlockedDays();

      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _especialistaSeleccionado = '';
        _horasDisponibles = List.from(horariosTotales);
      });

      await NotificationsService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        servicio: widget.negocio,
        especialista: _especialistaSeleccionado,
        scheduledDate: fechaCompleta.subtract(const Duration(hours: 24)),
      );

    } catch (e) {
      _mostrar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }


  // ─── Build ────────────────────────────────────────────────────────────────────

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFB39DDB)],
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
                      'assets/images/LogoAlphaAppFisioterapia.png',
                      width: screenWidth * 0.9,
                      height: 120,
                    ),

                    const SizedBox(height: 20),

                    // ── Calendario ──────────────────────────────────────────
                    _CalendarioCard(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      reservasPorDia: _reservasPorDia,
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                          // Resetear si el especialista no trabaja este día
                          if (!_especialistasFiltrados.contains(_especialistaSeleccionado)) {
                            _especialistaSeleccionado = '';
                            _horaSeleccionada = '';
                            _horasDisponibles = [];
                          }
                        });
                        _actualizarHorasDisponibles();
                      },
                    ),

                    const SizedBox(height: 30),

                    // ── Dropdown especialista ───────────────────────────────
                    _DropdownCard(
                      label: 'Selecciona Especialista',
                      value: _especialistaSeleccionado.isEmpty
                          ? null
                          : _especialistaSeleccionado,
                      items: _especialistasFiltrados,
                      onChanged: (val) {
                        setState(() => _especialistaSeleccionado = val!);
                        _actualizarHorasDisponibles();
                      },
                    ),

                    const SizedBox(height: 15),

                    // ── Dropdown hora ───────────────────────────────────────
                    _DropdownCard(
                      label: 'Hora disponible',
                      value: _horaSeleccionada.isEmpty ? null : _horaSeleccionada,
                      items: _horasDisponibles,
                      onChanged: _selectedDay == null
                          ? null
                          : (val) => setState(() => _horaSeleccionada = val!),
                    ),

                    const SizedBox(height: 35),

                    // ── Botón reservar ──────────────────────────────────────
                    _BotonReservar(
                      loading: _loading,
                      screenWidth: screenWidth,
                      onPressed: _reservar,
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

// ─── Subwidgets privados ───────────────────────────────────────────────────────

class _CalendarioCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, int> reservasPorDia;
  final void Function(DateTime, DateTime) onDaySelected;

  const _CalendarioCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.reservasPorDia,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (d) => isSameDay(selectedDay, d),
        onDaySelected: onDaySelected,
        enabledDayPredicate: (day) => day.weekday != DateTime.sunday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF5E3B8C),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: Color(0xFF5E3B8C), // sábado igual que los días de semana
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: CalendarStyle(
          // Texto del sábado en morado, domingo en gris
          defaultTextStyle: const TextStyle(color: Colors.black87),
          weekendTextStyle: const TextStyle(color: Color(0xFF5E3B8C)),
          disabledTextStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          todayDecoration: const BoxDecoration(
            color: Color(0xFF9575CD),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final day = DateTime(date.year, date.month, date.day);
            final count = reservasPorDia[day] ?? 0;
            if (count == 0) return null;

            return Positioned(
              bottom: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: count >= 4 ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
          disabledBuilder: (context, date, focusedDay) {
            final day = DateTime(date.year, date.month, date.day);
            final count = reservasPorDia[day] ?? 0;

            if (count >= _kMaxSlotsPorDia) {
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.6),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

class _DropdownCard extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;

  const _DropdownCard({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        alignment: AlignmentDirectional.center,
        initialValue: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        hint: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
        selectedItemBuilder: (context) => items
            .map((c) => Center(
                  child: Text(
                    c,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                ))
            .toList(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        dropdownColor: Colors.white.withValues(alpha: 0.95),
        items: items
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Center(child: Text(c)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _BotonReservar extends StatelessWidget {
  final bool loading;
  final double screenWidth;
  final VoidCallback onPressed;

  const _BotonReservar({
    required this.loading,
    required this.screenWidth,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth * 0.7,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 55,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'RESERVAR',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}