import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ---------------------------------------------------------------------------
// Tipos auxiliares
// ---------------------------------------------------------------------------

/// Agrupa las reservas por día y, dentro de cada día, por "hora - nombre de clase".
typedef _AgendaMap = Map<String, Map<String, List<Map<String, dynamic>>>>;

// ---------------------------------------------------------------------------
// Constantes de estilo
// ---------------------------------------------------------------------------

const _kAccent    = Color(0xFF64B5F6);
const _kDark      = Color(0xFF1E293B);
const _kMid       = Color(0xFF334155);
const _kGradient  = LinearGradient(
  begin: Alignment.topLeft,
  end:   Alignment.bottomRight,
  colors: [_kDark, _kMid, _kAccent],
);

// ---------------------------------------------------------------------------
// Widget principal
// ---------------------------------------------------------------------------

class AgendaWorkerPage extends StatefulWidget {
  const AgendaWorkerPage({super.key});

  @override
  State<AgendaWorkerPage> createState() => _AgendaWorkerPageState();
}

class _AgendaWorkerPageState extends State<AgendaWorkerPage> {
  // Caché de nombres: userId -> "Nombre Apellidos"
  // Evita relanzar una query a Firestore por cada rebuild del Stream.
  final Map<String, String> _nombresCache = {};

  int  _previousCount    = 0;
  bool _isFirstLoad      = true;
  bool _localeInitialized = false;
  String _filtro         = 'Hoy';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null)
        .then((_) => setState(() => _localeInitialized = true));
  }

  // ---------------------------------------------------------------------------
  // Helpers de fecha
  // ---------------------------------------------------------------------------

  bool _esFechaValida(DateTime fecha) {
    final hoy = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return !fecha.isBefore(hoy);
  }

  bool _esHoy(DateTime fecha) {
    final now = DateTime.now();
    return fecha.year == now.year && fecha.month == now.month && fecha.day == now.day;
  }

  bool _esProximos7Dias(DateTime fecha) {
    final hoy    = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final limite = hoy.add(const Duration(days: 8));
    return !fecha.isBefore(hoy) && fecha.isBefore(limite);
  }

  // ---------------------------------------------------------------------------
  // Lógica de filtrado y agrupación (separada del build)
  // ---------------------------------------------------------------------------

  List<QueryDocumentSnapshot> _filtrarDocs(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['fechaHora'] == null) return false;
      final fecha = (data['fechaHora'] as Timestamp).toDate();
      if (!_esFechaValida(fecha)) return false;
      if (_filtro == 'Hoy')    return _esHoy(fecha);
      if (_filtro == '7 Días') return _esProximos7Dias(fecha);
      return true;
    }).toList();
  }

  _AgendaMap _agrupar(List<QueryDocumentSnapshot> docs) {
    final _AgendaMap resultado = {};
    for (final doc in docs) {
      final data  = doc.data() as Map<String, dynamic>;
      final fecha = (data['fechaHora'] as Timestamp).toDate();

      final keyDia      = DateFormat('yyyy-MM-dd').format(fecha);
      final keyClaseHora = '${data['hora']} - ${data['claseNombre']}';

      resultado
          .putIfAbsent(keyDia, () => {})
          .putIfAbsent(keyClaseHora, () => [])
          .add(data);
    }
    return resultado;
  }

  // ---------------------------------------------------------------------------
  // Resolución de nombre con caché
  // ---------------------------------------------------------------------------

  Future<String> _resolverNombre(String userId) async {
    if (_nombresCache.containsKey(userId)) return _nombresCache[userId]!;

    final snap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String nombre = 'Cliente';

    if (snap.exists) {
      final data      = snap.data() ?? {};
      final String n  = (data['nombre']    ?? '').toString().trim();
      final String ap = (data['apellidos'] ?? '').toString().trim();
      if (n.isNotEmpty || ap.isNotEmpty) nombre = '$n $ap'.trim();
    }

    _nombresCache[userId] = nombre;
    return nombre;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    if (!_localeInitialized) {
      return const Scaffold(
        backgroundColor: _kDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Agenda de Clases',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradient),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservas')
                .where('employeeID', isEqualTo: user.uid.trim())
                .orderBy('fechaHora')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final allDocs   = snapshot.data!.docs;
              final filtered  = _filtrarDocs(allDocs);
              final agrupadas = _agrupar(filtered);

              // Notificación de nueva reserva
              if (!_isFirstLoad && allDocs.length > _previousCount) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nueva reserva recibida'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              }
              _previousCount = allDocs.length;
              _isFirstLoad   = false;

              return Column(
                children: [
                  _TotalBanner(total: filtered.length),
                  _FiltroBar(
                    seleccionado: _filtro,
                    onChanged: (v) => setState(() => _filtro = v),
                  ),
                  Expanded(
                    child: agrupadas.isEmpty
                        ? const _EmptyState()
                        : _AgendaListView(
                            agrupadas:      agrupadas,
                            esHoy:          _esHoy,
                            resolverNombre: _resolverNombre,
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
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _TotalBanner extends StatelessWidget {
  const _TotalBanner({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_search, color: _kAccent),
                const SizedBox(width: 12),
                Text(
                  'Alumnos en lista: $total',
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
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

class _FiltroBar extends StatelessWidget {
  const _FiltroBar({required this.seleccionado, required this.onChanged});
  final String seleccionado;
  final ValueChanged<String> onChanged;

  static const _opciones = ['Todas', 'Hoy', '7 Días'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _opciones.map((filtro) {
          final selected = seleccionado == filtro;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filtro),
              selected: selected,
              onSelected: (_) => onChanged(filtro),
              backgroundColor:  _kMid,
              selectedColor:    _kAccent,
              labelStyle: TextStyle(
                color:      selected ? _kDark : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
}

class _AgendaListView extends StatelessWidget {
  const _AgendaListView({
    required this.agrupadas,
    required this.esHoy,
    required this.resolverNombre,
  });

  final _AgendaMap agrupadas;
  final bool Function(DateTime) esHoy;
  final Future<String> Function(String) resolverNombre;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dias        = agrupadas.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: dias.length,
      itemBuilder: (context, index) {
        final keyDia   = dias[index];
        final fechaDia = DateTime.parse(keyDia);
        final clases   = agrupadas[keyDia]!;

        return _FadeInSlide(
          delay: Duration(milliseconds: index * 150),
          child: Column(
            children: [
              _DiaHeader(fecha: fechaDia, esHoy: esHoy),
              ...clases.entries.map((entry) => _ClaseTile(
                    titulo:         entry.key,
                    alumnos:        entry.value,
                    screenWidth:    screenWidth,
                    resolverNombre: resolverNombre,
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _DiaHeader extends StatelessWidget {
  const _DiaHeader({required this.fecha, required this.esHoy});
  final DateTime fecha;
  final bool Function(DateTime) esHoy;

  @override
  Widget build(BuildContext context) {
    final titulo = esHoy(fecha)
        ? 'HOY'
        : DateFormat('EEEE, d MMMM', 'es').format(fecha).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white12, endIndent: 20)),
          Text(
            titulo,
            style: const TextStyle(
              color: _kAccent, fontWeight: FontWeight.bold,
              fontSize: 12, letterSpacing: 1.5,
            ),
          ),
          const Expanded(child: Divider(color: Colors.white12, indent: 20)),
        ],
      ),
    );
  }
}

// Tarjeta desplegable con lista de alumnos.
// Usa FutureBuilder únicamente para las entradas que aún no están en caché.
class _ClaseTile extends StatelessWidget {
  const _ClaseTile({
    required this.titulo,
    required this.alumnos,
    required this.screenWidth,
    required this.resolverNombre,
  });

  final String titulo;
  final List<Map<String, dynamic>> alumnos;
  final double screenWidth;
  final Future<String> Function(String) resolverNombre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:  screenWidth > 600 ? 480 : screenWidth * 0.95,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:  Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor:          Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:        _kAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${alumnos.length} pers.',
                      style: const TextStyle(
                        color: _kAccent, fontWeight: FontWeight.bold, fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        Colors.black.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    children: alumnos
                        .map((alum) => _AlumnoRow(
                              userId:         alum['userId'] ?? '',
                              resolverNombre: resolverNombre,
                            ))
                        .toList(),
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

class _AlumnoRow extends StatelessWidget {
  const _AlumnoRow({required this.userId, required this.resolverNombre});
  final String userId;
  final Future<String> Function(String) resolverNombre;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: resolverNombre(userId),
      builder: (context, snap) {
        // Skeleton mientras carga
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.white10),
                const SizedBox(width: 12),
                Container(
                  width: 140, height: 14,
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.person, size: 16, color: _kAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  snap.data ?? 'Cliente',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                  ),
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
  }
}

// ---------------------------------------------------------------------------
// Animación de entrada
// ---------------------------------------------------------------------------

class _FadeInSlide extends StatelessWidget {
  const _FadeInSlide({required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500) + delay,
      curve:    Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child:  child,
        ),
      ),
      child: child,
    );
  }
}