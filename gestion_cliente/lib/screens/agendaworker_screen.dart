import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AgendaWorkerPage extends StatefulWidget {
  const AgendaWorkerPage({super.key});

  @override
  State<AgendaWorkerPage> createState() => _AgendaWorkerPageState();
}

class _AgendaWorkerPageState extends State<AgendaWorkerPage> {
  int _previousCount = 0;
  bool _isFirstLoad = true;
  bool _localeInitialized = false;
  String _filtroSeleccionado = 'Hoy'; 

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      setState(() => _localeInitialized = true);
    });
  }

  // Ocultar días pasados
  bool _esFechaValida(DateTime fecha) {
    final ahora = DateTime.now();
    final hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);
    return fecha.isAfter(hoyInicio.subtract(const Duration(seconds: 1)));
  }

  bool _esHoy(DateTime date) {
    final ahora = DateTime.now();
    return date.year == ahora.year && date.month == ahora.month && date.day == ahora.day;
  }

  // Ventana 7 días desde hoy
  bool _esProximos7Dias(DateTime date) {
    final ahora = DateTime.now();
    final hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);
    final limite = hoyInicio.add(const Duration(days: 8)); // Hasta el final del 7º día
    return date.isAfter(hoyInicio.subtract(const Duration(seconds: 1))) && date.isBefore(limite);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    if (user == null) return const Scaffold(body: Center(child: Text('No auth')));
    if (!_localeInitialized) {
      return const Scaffold(backgroundColor: Color(0xFF1E293B), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Agenda de Clases', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservas')
                .where('employeeID', isEqualTo: user.uid.trim())
                .orderBy('fechaHora', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));

              final todasLasDocs = snapshot.data!.docs;

              final reservasFiltradas = todasLasDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['fechaHora'] == null) return false;
                final DateTime fecha = (data['fechaHora'] as Timestamp).toDate();
                
                if (!_esFechaValida(fecha)) return false; 
                if (_filtroSeleccionado == 'Hoy') return _esHoy(fecha);
                if (_filtroSeleccionado == '7 Días') return _esProximos7Dias(fecha);
                return true; 
              }).toList();

                if (!_isFirstLoad && todasLasDocs.length > _previousCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Nueva reserva recibida! 📅'), backgroundColor: Colors.green),
                    );
                  });
                }
                _previousCount = todasLasDocs.length;
                _isFirstLoad = false;

              // AGRUPACIÓN: Día -> Hora+Clase -> Alumnos
              Map<String, Map<String, List<Map<String, dynamic>>>> agrupadas = {};

              for (var doc in reservasFiltradas) {
                final data = doc.data() as Map<String, dynamic>;
                final DateTime fecha = (data['fechaHora'] as Timestamp).toDate();
                
                String keyDia = DateFormat('yyyy-MM-dd').format(fecha);
                String keyClaseHora = "${data['hora']} - ${data['claseNombre']}";

                if (!agrupadas.containsKey(keyDia)) agrupadas[keyDia] = {};
                if (!agrupadas[keyDia]!.containsKey(keyClaseHora)) agrupadas[keyDia]![keyClaseHora] = [];
                
                agrupadas[keyDia]![keyClaseHora]!.add(data);
              }

              return Column(
                children: [
                  _buildTotalBanner(reservasFiltradas.length),
                  _buildFiltros(),

                  Expanded(
                    child: agrupadas.isEmpty
                        ? _buildEstadoVacio()
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: agrupadas.entries.map((entryDia) {
                              int indexDia = agrupadas.keys.toList().indexOf(entryDia.key);
                              DateTime fechaDia = DateTime.parse(entryDia.key);
                              return FadeInSlide(
                                delayMilliseconds: indexDia * 150, // Animación de entrada escalonada
                                child: Column(
                                  children: [
                                    _buildHeaderDia(fechaDia), 
                                    ...entryDia.value.entries.map((entryClase) {
                                      return _buildTarjetaClaseDesplegable(entryClase.key, entryClase.value, screenWidth);
                                    }),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBanner(int total) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_search, color: Color(0xFF64B5F6)),
                const SizedBox(width: 12),
                Text(
                  'Alumnos en lista: $total',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Todas', 'Hoy', '7 Días'].map((filtro) {
          bool isSel = _filtroSeleccionado == filtro;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filtro),
              selected: isSel,
              onSelected: (v) => setState(() => _filtroSeleccionado = filtro),
              backgroundColor: const Color(0xFF334155),
              selectedColor: const Color(0xFF64B5F6),
              labelStyle: TextStyle(color: isSel ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  // WIDGET: Cabecera Centrada de Fecha
  Widget _buildHeaderDia(DateTime fecha) {
    String titulo = _esHoy(fecha) ? "HOY" : DateFormat('EEEE, d MMMM', 'es').format(fecha).toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white12, endIndent: 20)),
          Text(
            titulo,
            style: const TextStyle(color: Color(0xFF64B5F6), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
          ),
          const Expanded(child: Divider(color: Colors.white12, indent: 20)),
        ],
      ),
    );
  }
  // WIDGET: Estado Vacío Estilizado
  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 50, color: Colors.white30),
          SizedBox(height: 14),
          Text(
            'No hay reservas programadas',
            style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // WIDGET: Tarjeta Desplegable
  Widget _buildTarjetaClaseDesplegable(String titulo, List<Map<String, dynamic>> alumnos, double width) {
    return Center(
      child: Container(
        width: width > 600 ? 480 : width * 0.95,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${alumnos.length} pers.",
                      style: const TextStyle(color: Color(0xFF64B5F6), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    children: alumnos.map((alum) {
                      final String idDelUsuario = alum['userId'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(idDelUsuario).get(),
                        builder: (context, userSnapshot) {
                          
                          // EFECTO DE CARGA SKELETON
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.white10),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 140,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          String clienteMostrar = "Cliente sin nombre"; 

                          if (userSnapshot.hasData && userSnapshot.data!.exists) {
                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            if (userData != null) {
                              final String nombre = (userData['nombre'] ?? '').toString().trim();
                              final String apellidos = (userData['apellidos'] ?? '').toString().trim();
                              
                              if (nombre.isNotEmpty || apellidos.isNotEmpty) {
                                clienteMostrar = "$nombre $apellidos".trim();
                              }
                            }
                          } else {
                            clienteMostrar = "Cliente"; 
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8), 
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Color(0xFF64B5F6)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    clienteMostrar, 
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.check_circle_outline, size: 16, color: Colors.white24),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGET COHESIVO
class FadeInSlide extends StatelessWidget {
  final Widget child;
  final int delayMilliseconds;

  const FadeInSlide({super.key, required this.child, required this.delayMilliseconds});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      // Espera el delay correspondiente antes de arrancar la animación
      builder: (context, value, child) {
        return AnimatedOpacity(
          opacity: value,
          duration: Duration(milliseconds: delayMilliseconds),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}