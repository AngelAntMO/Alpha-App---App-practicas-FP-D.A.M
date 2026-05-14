// ============================================================
// ACADEMIA PAGE - SISTEMA DE RESERVAS MEJORADO
// ============================================================
//
// MEJORAS IMPLEMENTADAS:
//
// ✅ Clases dinámicas desde Firestore
// ✅ EmployeeID obligatorio para reservar
// ✅ Máximo 5 reservas activas SOLO en Academia
// ✅ Máximo 15 personas por clase + hora + día
// ✅ Un usuario NO puede reservar dos clases a la misma hora
// ✅ Un usuario SÍ puede reservar varias clases el mismo día
// ✅ Bloqueo de horas pasadas del día actual
// ✅ Indicadores visuales en calendario
// ✅ Horas muestran plazas disponibles
// ✅ Código comentado para el equipo
//
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

// ============================================================
// CONSTANTES
// ============================================================

const _kColeccionReservas = 'reservas';
const _kColeccionClases = 'clases';

const _kEstadoActiva = 'activa';
const _kEstadoFinalizada = 'finalizada';

const _kMaxReservasAcademia = 5;
const _kMaxPorClaseHora = 15;

// ============================================================
// WIDGET PRINCIPAL
// ============================================================

class AcademiaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const AcademiaPage({super.key, required this.userId, required this.negocio});

  @override
  State<AcademiaPage> createState() => _AcademiaPageState();
}

class _AcademiaPageState extends State<AcademiaPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // VARIABLES CALENDARIO
  // ============================================================

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ============================================================
  // VARIABLES UI
  // ============================================================

  bool _loading = false;

  String _claseSeleccionada = '';
  String _horaSeleccionada = '';

  // ============================================================
  // DATOS DINÁMICOS
  // ============================================================

  List<String> _clases = [];

  // Lista visual de horas:
  // Ej:
  // 16:00 (12/15)
  List<Map<String, dynamic>> _horasDisponibles = [];

  // Días con reservas para pintar puntos
  final Map<DateTime, String> _estadoDias = {};

  // ============================================================
  // HORARIOS FIJOS
  // ============================================================

  final List<String> horariosTotales = ['16:00', '17:00', '18:00', '19:00'];

  // ============================================================
  // REFERENCIA NEGOCIO
  // ============================================================

  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('es_ES', null);

    _cargarClases();
    _cargarEstadoDias();
    _actualizarReservasPasadas();
  }

  // ============================================================
  // CARGAR CLASES DINÁMICAS DESDE FIRESTORE
  // ============================================================

  Future<void> _cargarClases() async {
    try {
      final snapshot = await _db
          .collection(_kColeccionClases)
          .where('negocioRef', isEqualTo: negocioRef)
          .get();

      final clases = snapshot.docs
          .map((doc) => doc['nombre'].toString())
          .toList();

      clases.sort();

      if (mounted) {
        setState(() {
          _clases = clases;
        });
      }
    } catch (e) {
      debugPrint('Error cargando clases: $e');
    }
  }

  // ============================================================
  // ACTUALIZAR RESERVAS PASADAS A FINALIZADA
  // ============================================================

  Future<void> _actualizarReservasPasadas() async {
    try {
      final ahora = Timestamp.fromDate(DateTime.now());

      final snapshot = await _db
          .collection(_kColeccionReservas)
          .where('estado', isEqualTo: _kEstadoActiva)
          .where('fechaHora', isLessThan: ahora)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'estado': _kEstadoFinalizada});
      }
    } catch (e) {
      debugPrint('Error actualizando reservas: $e');
    }
  }

  // ============================================================
  // CARGAR ESTADO VISUAL DEL CALENDARIO
  // ============================================================

  Future<void> _cargarEstadoDias() async {
    try {
      final inicio = DateTime(_focusedDay.year, _focusedDay.month, 1);

      final fin = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final snapshot = await _db
          .collection(_kColeccionReservas)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('estado', isEqualTo: _kEstadoActiva)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .get();

      final Map<DateTime, String> estados = {};

      for (var doc in snapshot.docs) {
        final fecha = (doc['fecha'] as Timestamp).toDate();

        final dia = DateTime(fecha.year, fecha.month, fecha.day);

        final userId = doc['userId'];

        // Si el usuario tiene reserva → verde
        if (userId == widget.userId) {
          estados[dia] = 'verde';
        } else {
          estados.putIfAbsent(dia, () => 'naranja');
        }
      }

      if (mounted) {
        setState(() {
          _estadoDias.clear();
          _estadoDias.addAll(estados);
        });
      }
    } catch (e) {
      debugPrint('Error estado días: $e');
    }
  }

  // ============================================================
  // COMPROBAR SI UNA HORA YA PASÓ
  // ============================================================

  bool _horaYaPasada(String hora) {
    if (_selectedDay == null) return false;

    final ahora = DateTime.now();

    final partes = hora.split(':');

    final fechaHora = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    return fechaHora.isBefore(ahora);
  }

  // ============================================================
  // ACTUALIZAR HORAS DISPONIBLES
  // ============================================================

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) {
      return;
    }

    setState(() => _loading = true);

    try {
      final fechaBusqueda = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      final snapshot = await _db
          .collection(_kColeccionReservas)
          .where('negocioRef', isEqualTo: negocioRef)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('estado', isEqualTo: _kEstadoActiva)
          .get();

      final List<Map<String, dynamic>> horas = [];

      for (String hora in horariosTotales) {
        // ======================================================
        // NO MOSTRAR HORAS PASADAS
        // ======================================================

        if (_horaYaPasada(hora)) {
          continue;
        }

        // ======================================================
        // RESERVAS DE ESA CLASE + HORA
        // ======================================================

        final reservasClaseHora = snapshot.docs.where((doc) {
          return doc['claseNombre'] == _claseSeleccionada &&
              doc['hora'] == hora;
        }).toList();

        // ======================================================
        // ¿USUARIO YA TIENE ESA HORA RESERVADA?
        // ======================================================

        final usuarioYaReservoHora = snapshot.docs.any((doc) {
          return doc['userId'] == widget.userId && doc['hora'] == hora;
        });

        final total = reservasClaseHora.length;

        final llena = total >= _kMaxPorClaseHora;

        // ======================================================
        // SI YA TIENE ESA HORA → NO MOSTRAR
        // ======================================================

        if (usuarioYaReservoHora) {
          continue;
        }

        horas.add({
          'hora': hora,
          'ocupadas': total,
          'llena': llena,
          'texto': llena
              ? '$hora - COMPLETA'
              : '$hora ($total/$_kMaxPorClaseHora)',
        });
      }

      if (mounted) {
        setState(() {
          _horasDisponibles = horas;

          if (!_horasDisponibles.any((h) => h['hora'] == _horaSeleccionada)) {
            _horaSeleccionada = '';
          }

          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error horas: $e');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ============================================================
  // RESERVAR
  // ============================================================

  Future<void> _reservar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_selectedDay == null ||
        _claseSeleccionada.isEmpty ||
        _horaSeleccionada.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {
      // ========================================================
      // OBTENER DOCUMENTO DE CLASE
      // ========================================================

      final claseDoc = await _db
          .collection(_kColeccionClases)
          .doc(_claseSeleccionada)
          .get();

      // ========================================================
      // COMPROBAR QUE EXISTE
      // ========================================================

      if (!claseDoc.exists) {
        throw Exception('La clase no existe');
      }

      // ========================================================
      // OBTENER EMPLOYEE ID
      // ========================================================

      final employeeID = claseDoc.data()?['employeeID'];

      // ========================================================
      // VALIDAR PROFESOR ASIGNADO
      // ========================================================

      if (employeeID == null || employeeID.toString().trim().isEmpty) {
        throw Exception('Esta clase todavía no tiene profesor asignado');
      }

      // ========================================================
      // FECHA BASE
      // ========================================================

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

      // ========================================================
      // TRANSACCIÓN
      // ========================================================

      final reservasRef = _db.collection(_kColeccionReservas);

        //
        // VALIDAR RESERVAS ACTIVAS USUARIO
        //

        final userReservas = await reservasRef
            .where('userId', isEqualTo: widget.userId)
            .where('negocioRef', isEqualTo: negocioRef)
            .where('estado', isEqualTo: _kEstadoActiva)
            .get();

        if (userReservas.docs.length >= _kMaxReservasAcademia) {

          _mostrarMensaje(
            'Ya tienes 5 reservas activas en Academia',
          );

          if (mounted) {
            setState(() => _loading = false);
          }

          return;
        }

        //
        // RESERVAS DEL DÍA
        //

        final reservasDia = await reservasRef
            .where('negocioRef', isEqualTo: negocioRef)
            .where('fecha', isEqualTo: Timestamp.fromDate(fechaBase))
            .where('estado', isEqualTo: _kEstadoActiva)
            .get();

        //
        // YA TIENE ESA HORA
        //

        final yaTieneHora = reservasDia.docs.any((doc) {
          return doc['userId'] == widget.userId &&
              doc['hora'] == _horaSeleccionada;
        });

        if (yaTieneHora) {

          _mostrarMensaje(
            'Ya tienes una reserva a esa hora',
          );

          if (mounted) {
            setState(() => _loading = false);
          }

          return;
        }

        //
        // CLASE COMPLETA
        //

        final reservasClaseHora = reservasDia.docs.where((doc) {
          return doc['claseNombre'] == _claseSeleccionada &&
              doc['hora'] == _horaSeleccionada;
        }).toList();

        if (reservasClaseHora.length >= _kMaxPorClaseHora) {

          _mostrarMensaje(
            'La clase está completa',
          );

          if (mounted) {
            setState(() => _loading = false);
          }

          return;
        }

        //
        // CREAR RESERVA
        //

        final nuevaReserva = reservasRef.doc();

        await nuevaReserva.set({
          // ====================================================
          // USUARIO
          // ====================================================
          'userId': widget.userId,

          'cliente': user?.displayName?.isNotEmpty == true
              ? user!.displayName
              : user?.email ?? 'Usuario desconocido',

          // ====================================================
          // NEGOCIO
          // ====================================================
          'negocioNombre': widget.negocio,

          'negocioRef': negocioRef,

          // ====================================================
          // CLASE
          // ====================================================
          'claseNombre': _claseSeleccionada,

          'claseRef': _db.collection(_kColeccionClases).doc(_claseSeleccionada),

          // ====================================================
          // EMPLEADO
          // ====================================================
          'employeeID': employeeID,

          // ====================================================
          // FECHAS
          // ====================================================
          'fecha': Timestamp.fromDate(fechaBase),

          'fechaHora': Timestamp.fromDate(fechaHora),

          'hora': _horaSeleccionada,

          // ====================================================
          // ESTADO
          // ====================================================
          'estado': _kEstadoActiva,

          // ====================================================
          // TIMESTAMP CREACIÓN
          // ====================================================
          'timestamp': FieldValue.serverTimestamp(),
        });

      // ========================================================
      // MENSAJE OK
      // ========================================================

      _mostrarMensaje('Reserva confirmada');

      // ========================================================
      // RECARGAR DATOS
      // ========================================================

      await _cargarEstadoDias();

      await _actualizarHorasDisponibles();

      // ========================================================
      // RESET UI
      // ========================================================

      if (mounted) {
        setState(() {
          _horaSeleccionada = '';
        });
      }
    } catch (e) {
      String errorTexto = e.toString();

      errorTexto = errorTexto.replaceFirst('Exception: ', '');

      errorTexto = errorTexto.replaceAll(RegExp(r'\[.*?\]'), '');

      errorTexto = errorTexto.trim();

      _mostrarMensaje(errorTexto);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // ========================================================
      // APPBAR
      // ========================================================
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

      // ========================================================
      // BODY
      // ========================================================
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
            padding: const EdgeInsets.all(24),

            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),

                child: Column(
                  children: [
                    // ====================================================
                    // LOGO
                    // ====================================================
                    Image.asset(
                      'assets/images/LogoAlphaAppAcademia.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // CALENDARIO
                    // ====================================================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),

                        borderRadius: BorderRadius.circular(25),

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
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFFFA726),
                            shape: BoxShape.circle,
                          ),

                          todayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(
                              0xFFF57C00,
                            ), // color naranja para días de semana
                            fontWeight: FontWeight.w600,
                          ),

                          weekendStyle: TextStyle(
                            color: Color(
                              0xFFF57C00,
                            ), // sábado igual que los días de semana
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        focusedDay: _focusedDay,

                        enabledDayPredicate: (day) {
                          return day.weekday != DateTime.sunday;
                        },

                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),

                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _cargarEstadoDias();
                        },

                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;

                            _focusedDay = focusedDay;
                          });

                          _actualizarHorasDisponibles();
                        },

                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final estado = _estadoDias.entries
                                .where((e) => isSameDay(e.key, date))
                                .map((e) => e.value)
                                .firstOrNull;

                            if (estado == null) {
                              return null;
                            }

                            Color color = Colors.orange;

                            if (estado == 'verde') {
                              color = Colors.green;
                            }

                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ====================================================
                    // DROPDOWN CLASES
                    // ====================================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: DropdownButtonFormField<String>(
                        isExpanded: true,

                        initialValue: _claseSeleccionada.isEmpty
                            ? null
                            : _claseSeleccionada,

                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          labelText: 'Selecciona Clase',
                        ),

                        items: _clases.map((clase) {
                          return DropdownMenuItem(
                            value: clase,
                            child: Center(child: Text(clase)),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            _claseSeleccionada = value!;
                          });

                          _actualizarHorasDisponibles();
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ====================================================
                    // DROPDOWN HORAS
                    // ====================================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: DropdownButtonFormField<String>(
                        isExpanded: true,

                        initialValue: _horaSeleccionada.isEmpty
                            ? null
                            : _horaSeleccionada,

                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          labelText: 'Selecciona Hora',
                        ),

                        items: _horasDisponibles.map((h) {
                          return DropdownMenuItem<String>(
                            value: h['hora'] as String,
                            enabled: !(h['llena'] as bool),
                            child: Center(child: Text(h['texto'] as String)),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            _horaSeleccionada = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ====================================================
                    // BOTÓN RESERVAR
                    // ====================================================
                    SizedBox(
                      width: screenWidth * 0.7,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: _loading ? null : _reservar,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
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
                                    'RESERVAR',
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
