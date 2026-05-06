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
const _kMaxPorHora = 10;
const _kMaxReservas = 3;

class PeluqueriaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const PeluqueriaPage({
    super.key,
    required this.userId,
    required this.negocio,
  });

  @override
  State<PeluqueriaPage> createState() => _PeluqueriaPageState();
}

class _PeluqueriaPageState extends State<PeluqueriaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<String> _horasDisponibles = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference get negocioRef =>
      _db.collection('negocios').doc(widget.negocio);

  String _horaSeleccionada = '';
  String _actividadSeleccionada = '';
  bool _loading = false;

  final List<String> actividades = [
    'Corte Caballero',
    'Corte Dama',
    'Coloración',
    'Tratamiento Capilar',
    'Barbería',
  ];

  final List<String> horariosTotales = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _actividadSeleccionada.isEmpty) return;

    setState(() => _loading = true);

    DateTime fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final snapshot = await _db
        .collection(_kColeccion)
        .where(_kCampoNegocioRef, isEqualTo: negocioRef)
        .where(_kCampoFecha, isEqualTo: Timestamp.fromDate(fecha))
        .where(_kCampoClase, isEqualTo: _actividadSeleccionada)
        .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
        .get();

    Map<String, int> conteo = {};
    List<String> mias = [];

    for (var doc in snapshot.docs) {
      String hora = doc[_kCampoHora] as String;
      String uid = doc[_kCampoUserId] as String;

      conteo[hora] = (conteo[hora] ?? 0) + 1;

      if (uid == widget.userId) {
        mias.add(hora);
      }
    }

    setState(() {
      _horasDisponibles = horariosTotales.where((h) {
        int total = conteo[h] ?? 0;
        bool yaEstoy = mias.contains(h);
        return total < _kMaxPorHora && !yaEstoy;
      }).toList();

      if (!_horasDisponibles.contains(_horaSeleccionada)) {
        _horaSeleccionada = '';
      }

      _loading = false;
    });
  }

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _actividadSeleccionada.isEmpty) {
      _msg("Completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    DateTime fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final check = await _db
        .collection(_kColeccion)
        .where(_kCampoNegocioRef, isEqualTo: negocioRef)
        .where(_kCampoFecha, isEqualTo: Timestamp.fromDate(fecha))
        .where(_kCampoClase, isEqualTo: _actividadSeleccionada)
        .where(_kCampoHora, isEqualTo: _horaSeleccionada)
        .where(_kCampoEstado, isEqualTo: _kEstadoActiva)
        .get();

    if (check.docs.any((d) => d[_kCampoUserId] == widget.userId)) {
      _msg("Ya tienes reserva");
      setState(() => _loading = false);
      return;
    }

    if (check.docs.length >= _kMaxReservas) {
      _msg("Cupo lleno");
      setState(() => _loading = false);
      return;
    }
await _db.collection(_kColeccion).add({
  _kCampoUserId: widget.userId,
  _kCampoNegocioRef: negocioRef,
  'negocioNombre': widget.negocio,

  _kCampoClase: _actividadSeleccionada,

  'claseRef': FirebaseFirestore.instance
      .collection('clases')
      .doc(_actividadSeleccionada),

  _kCampoFecha: Timestamp.fromDate(fecha),
  _kCampoHora: _horaSeleccionada,

  'fechaHora': Timestamp.fromDate(DateTime(
    fecha.year,
    fecha.month,
    fecha.day,
    int.parse(_horaSeleccionada.split(':')[0]),
    int.parse(_horaSeleccionada.split(':')[1]),
  )),

  _kCampoEstado: _kEstadoActiva,
  'timestamp': FieldValue.serverTimestamp(),
});

    _msg("Reserva confirmada");

    setState(() {
      _selectedDay = null;
      _horaSeleccionada = '';
      _actividadSeleccionada = '';
      _horasDisponibles = List.from(horariosTotales);
    });

    if (mounted) setState(() => _loading = false);
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
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
              Color(0xFFFEFBDD),
              Color(0xFFE1D3BB),
              Color(0xFFD7A894),
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
                      'assets/images/LogoAlphaAppPeluquería.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TableCalendar(
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
                          _actualizarHorasDisponibles();
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFFD7A894), // amarillo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFD7A894),

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

                    
                    _buildDropdown(
                      label: "Actividad",
                      value: _actividadSeleccionada,
                      items: actividades,
                      onChanged: (v) {
                        setState(() => _actividadSeleccionada = v!);
                        _actualizarHorasDisponibles();
                      },
                    ),
                    const SizedBox(height: 15),

                    
                    _buildDropdown(
                      label: "Hora disponible",
                      value: _horaSeleccionada,
                      items: _horasDisponibles,
                      onChanged: _selectedDay == null
                          ? null
                          : (v) => setState(() => _horaSeleccionada = v!),
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
