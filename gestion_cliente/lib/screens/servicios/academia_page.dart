import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

const _kColeccion = 'reservas';
const _kEstadoActiva = 'activa';
const _kCampoFecha = 'fecha';
const _kCampoHora = 'hora';
const _kCampoEstado = 'estado';
const _kCampoUserId = 'userId';
const _kCampoNegocioRef = 'negocioRef';
const _kCampoClase = 'claseNombre';
const _kMaxReservas = 3;
const _kMaxPorHora = 10;

class AcademiaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const AcademiaPage({super.key, required this.userId, required this.negocio});

  @override
  State<AcademiaPage> createState() => _AcademiaPageState();
}

class _AcademiaPageState extends State<AcademiaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _blockedDays = [];
  List<String> _horasDisponibles = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  String _horaSeleccionada = '';
  String _claseSeleccionada = '';
  bool _loading = false;

  final List<String> clases = ['Inglés', 'Matemáticas', 'Repaso'];
  final List<String> horariosTotales = ['16:00', '17:00', '18:00', '19:00'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _fetchBlockedDays() async {
    try {
      final inicio = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final fin = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final snapshot = await _db
          .collection(_kColeccion)
          .where(_kCampoNegocioRef, isEqualTo: negocioRef)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .where(
            _kCampoFecha,
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
          )
          .where(_kCampoFecha, isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .get();
      final Set<DateTime> blocked = {};

      for (var doc in snapshot.docs) {
        final fecha = (doc['fecha'] as Timestamp).toDate();

        blocked.add(DateTime(fecha.year, fecha.month, fecha.day));
      }

      if (mounted) {
        setState(() {
          _blockedDays = blocked.toList();
        });
      }
    } catch (e) {
      debugPrint("Error días bloqueados: $e");
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

      final Map<String, int> conteoPorHora = {};
      final Set<String> misHoras = {};

      for (var doc in snapshot.docs) {
        final hora = doc[_kCampoHora] as String;
        final userId = doc[_kCampoUserId] as String;

        conteoPorHora[hora] = (conteoPorHora[hora] ?? 0) + 1;

        if (userId == widget.userId) {
          misHoras.add(hora);
        }
      }

      setState(() {
        _horasDisponibles = horariosTotales.where((h) {
          final total = conteoPorHora[h] ?? 0;
          final yaReservado = misHoras.contains(h);

          return total < _kMaxPorHora && !yaReservado;
        }).toList();

        if (!_horasDisponibles.contains(_horaSeleccionada)) {
          _horaSeleccionada = '';
        }

        _loading = false;
      });
    } catch (e) {
      debugPrint("Error horas disponibles: $e");
      setState(() => _loading = false);
    }
  }

Future<void> _reservar() async {
  if (_selectedDay == null ||
      _horaSeleccionada.isEmpty ||
      _claseSeleccionada.isEmpty) {
    _mostrarMensaje('Completa todos los campos');
    return;
  }

  final fechaBase = DateTime(
    _selectedDay!.year,
    _selectedDay!.month,
    _selectedDay!.day,
  );

  final partesHora = _horaSeleccionada.split(':');

  final fechaHora = DateTime(
    fechaBase.year,
    fechaBase.month,
    fechaBase.day,
    int.parse(partesHora[0]),
    int.parse(partesHora[1]),
  );

  setState(() => _loading = true);

  final reservasRef = _db.collection(_kColeccion);

  try {
  
    final userQuery = await reservasRef
    .where(_kCampoUserId, isEqualTo: widget.userId)
    .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
    .where(_kCampoNegocioRef, isEqualTo: negocioRef)
    .get();

    if (userQuery.docs.length >= _kMaxReservas) {
      _mostrarMensaje('Máximo $_kMaxReservas reservas activas');
      return;
    }
    await _db.runTransaction((transaction) async {

      final slotQuery = await reservasRef
          .where(_kCampoNegocioRef, isEqualTo: negocioRef)
          .where(_kCampoFecha, isEqualTo: Timestamp.fromDate(fechaBase))
          .where(_kCampoHora, isEqualTo: _horaSeleccionada)
          .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
          .get();

      if (slotQuery.docs.length >= _kMaxPorHora) {
        throw Exception('Cupo completo para esta hora');
      }

      final yaReservado = slotQuery.docs.any(
        (doc) => doc['userId'] == widget.userId,
      );

      if (yaReservado) {
        throw Exception('Ya tienes una reserva en este horario');
      }

      final docRef = reservasRef.doc();

      transaction.set(docRef, {
        _kCampoUserId: widget.userId,
        'negocioRef': negocioRef,
        'negocioNombre': widget.negocio,
        'claseNombre': _claseSeleccionada,
        'claseRef': FirebaseFirestore.instance
            .collection('clases')
            .doc(_claseSeleccionada),
        'fecha': Timestamp.fromDate(fechaBase),
        'hora': _horaSeleccionada,
        'fechaHora': Timestamp.fromDate(fechaHora),
        'estado': 'activa',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
    _mostrarMensaje('Reserva confirmada');

    await _fetchBlockedDays();

    setState(() {
      _selectedDay = null;
      _horaSeleccionada = '';
      _claseSeleccionada = '';
      _horasDisponibles = List.from(horariosTotales);
    });

  } catch (e, stack) {
    debugPrint("ERROR REAL: $e");
    debugPrintStack(stackTrace: stack);

    _mostrarMensaje(e.toString().replaceAll('Exception: ', ''));
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  void _mostrarMensaje(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

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
            colors: [Color(0xFFF5F5F5), Color(0xFFFFB74D), Color(0xFFF57C00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/LogoAlphaAppAcademia.png',
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
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 94, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: const CalendarStyle(
                          defaultTextStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
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
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,
                        initialValue: _claseSeleccionada.isEmpty
                            ? null
                            : _claseSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona Materia',
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        selectedItemBuilder: (context) {
                          return clases.map((c) {
                            return Center(
                              child: Text(
                                c,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList();
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        dropdownColor: Colors.white.withValues(alpha: 0.95),
                        items: clases.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Center(child: Text(c)),
                          );
                        }).toList(),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,
                        initialValue: _horaSeleccionada.isEmpty
                            ? null
                            : _horaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Hora disponible',
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        selectedItemBuilder: (context) {
                          return _horasDisponibles.map((h) {
                            return Center(
                              child: Text(
                                h,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList();
                        },
                        dropdownColor: Colors.white.withValues(alpha: 0.95),
                        items: _horasDisponibles.map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Center(child: Text(h)),
                          );
                        }).toList(),
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
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                                Color(0xFF64B5F6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 55,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
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
