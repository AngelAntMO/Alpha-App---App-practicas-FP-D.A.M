import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class EstadisticasAdmin extends StatefulWidget {
  const EstadisticasAdmin({super.key});

  @override
  State<EstadisticasAdmin> createState() => _EstadisticasAdminState();
}

class _EstadisticasAdminState extends State<EstadisticasAdmin>
    with SingleTickerProviderStateMixin {
  bool   _loading = true;
  String? _negocio;
  List<Map<String, dynamic>> _clases   = [];
  List<Map<String, dynamic>> _reservas = [];

  // Animación de entrada
  late AnimationController _entryCtrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _cargarDatos();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────
  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { setState(() => _loading = false); return; }

    final userDoc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    final negocios = userDoc.data()?['negocios'];
    if (negocios is! List || negocios.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    _negocio = negocios.first.toString();

    // Clases del negocio
    final clasesSnap = await FirebaseFirestore.instance
        .collection('clases')
        .where('negocioID', isEqualTo: _negocio)
        .get();

    _clases = clasesSnap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList();

    // EmployeeIDs con profesor asignado
    final empIds = _clases
        .map((c) => c['employeeID'] as String? ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    // Reservas filtradas por employeeID (whereIn soporta hasta 30)
    if (empIds.isNotEmpty) {
      final chunks = <List<String>>[];
      for (int i = 0; i < empIds.length; i += 30) {
        chunks.add(empIds.sublist(i, i + 30 > empIds.length ? empIds.length : i + 30));
      }
      for (final chunk in chunks) {
        final snap = await FirebaseFirestore.instance
            .collection('reservas')
            .where('employeeID', whereIn: chunk)
            .get();
        _reservas.addAll(snap.docs.map((d) => d.data()));
      }
    }

    if (mounted) {
      setState(() => _loading = false);
      _entryCtrl.forward();
    }
  }

  // ── Estadísticas calculadas ───────────────────────────────────────────────
  int get _total => _reservas.length;

  int get _estaSemana {
    final hoy   = DateTime.now();
    final lunes = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(Duration(days: hoy.weekday - 1));
    return _reservas.where((r) {
      if (r['fechaHora'] == null) return false;
      final f = (r['fechaHora'] as Timestamp).toDate();
      return f.isAfter(lunes.subtract(const Duration(seconds: 1)));
    }).length;
  }

  String get _claseTop {
    if (_reservas.isEmpty) return '—';
    final counts = <String, int>{};
    for (final r in _reservas) {
      final c = r['claseNombre'] as String? ?? 'Sin nombre';
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // Reservas agrupadas por semana (últimas 6 semanas, de más antigua a más reciente)
  List<int> get _porSemana {
    final now = DateTime.now();
    final counts = List.filled(6, 0);
    for (final r in _reservas) {
      if (r['fechaHora'] == null) continue;
      final f    = (r['fechaHora'] as Timestamp).toDate();
      final diff = now.difference(f).inDays;
      final sem  = diff ~/ 7;
      
      // CORRECCIÓN: Filtrar para evitar que fechas futuras resten índices inválidos
      if (sem >= 0 && sem < 6) {
        counts[5 - sem]++;
      }
    }
    return counts;
  }

  // Etiquetas de las semanas: lunes de cada semana
  List<String> get _labelsSemana {
    final now = DateTime.now();
    final lunes = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(6, (i) {
      final d = lunes.subtract(Duration(days: (5 - i) * 7));
      return DateFormat('d MMM', 'es_ES').format(d);
    });
  }

  // Reservas por clase
  Map<String, int> get _porClase {
    final counts = <String, int>{};
    for (final c in _clases) {
      counts[c['nombre'] as String? ?? c['id'] as String] = 0;
    }
    for (final r in _reservas) {
      final clase = r['claseNombre'] as String? ?? '';
      if (counts.containsKey(clase)) counts[clase] = counts[clase]! + 1;
    }
    return counts;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final titulo = _negocio == null
        ? 'Estadísticas'
        : 'Estadísticas · ${_negocio![0].toUpperCase()}${_negocio!.substring(1)}';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(titulo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
            : FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 110, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── KPI Cards ────────────────────────────────────────
                        Row(children: [
                          Expanded(child: _KpiCard(
                            valor:  '$_total',
                            label:  'Reservas totales',
                            icono:  Icons.confirmation_num_outlined,
                            color:  const Color(0xFF64B5F6),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _KpiCard(
                            valor:  '$_estaSemana',
                            label:  'Esta semana',
                            icono:  Icons.date_range_outlined,
                            color:  const Color(0xFF81C784),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _KpiCard(
                            valor:  '🏆',
                            label:  _claseTop,
                            icono:  null,
                            color:  const Color(0xFFFFB74D),
                          )),
                        ]),

                        const SizedBox(height: 30),

                        // ── Gráfica: reservas por semana ─────────────────────
                        _SeccionTitulo(
                          icono: Icons.show_chart,
                          texto: 'Tendencia semanal',
                          color: const Color(0xFF64B5F6),
                        ),
                        const SizedBox(height: 12),
                        _GlassCard(
                          child: _porSemana.every((v) => v == 0)
                              ? const _SinDatos()
                              : SizedBox(
                                  height: 200,
                                  child: _BarChartSemanal(
                                    valores:  _porSemana,
                                    etiquetas: _labelsSemana,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 28),

                        // ── Gráfica: reservas por clase ──────────────────────
                        _SeccionTitulo(
                          icono: Icons.bar_chart,
                          texto: 'Reservas por clase',
                          color: const Color(0xFF81C784),
                        ),
                        const SizedBox(height: 12),
                        _GlassCard(
                          child: _porClase.isEmpty || _porClase.values.every((v) => v == 0)
                              ? const _SinDatos()
                              : SizedBox(
                                  height: 220,
                                  child: _BarChartClase(datos: _porClase),
                                ),
                        ),

                        const SizedBox(height: 28),

                        // ── Tabla resumen por clase ──────────────────────────
                        _SeccionTitulo(
                          icono: Icons.list_alt_outlined,
                          texto: 'Detalle por clase',
                          color: const Color(0xFFCE93D8),
                        ),
                        const SizedBox(height: 12),
                        _GlassCard(
                          child: _porClase.isEmpty
                              ? const _SinDatos()
                                : Column(
                                  children: (_porClase.entries.toList()
                                      ..sort((a, b) => b.value.compareTo(a.value)))
                                    .map((e) => _FilaClase(
                                          nombre: e.key,
                                          count: e.value,
                                          max: _porClase.values.fold(0, (a, b) => a > b ? a : b),
                                        ))
                                    .toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  GRÁFICA: BARRAS POR SEMANA
// ═══════════════════════════════════════════════════════════════════════════════
class _BarChartSemanal extends StatelessWidget {
  final List<int>    valores;
  final List<String> etiquetas;

  const _BarChartSemanal({required this.valores, required this.etiquetas});

  @override
  Widget build(BuildContext context) {
    final maxY = valores.isEmpty
    ? 5.0
    : (valores.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // CORRECCIÓN: Usar group.x de forma segura para mapear el índice real
              final index = group.x.toInt();
              if (index < 0 || index >= etiquetas.length) {
                return null;
              }

              return BarTooltipItem(
                '${rod.toY.toInt()} reservas\n${etiquetas[index]}',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (maxY / 4).clamp(1, 999).toDouble(),
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();

                if (index < 0 || index >= etiquetas.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    etiquetas[index],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withAlpha(20),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          valores.length,
          (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: valores[i].toDouble(),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF64B5F6)],
                    begin: Alignment.bottomCenter,
                    end:   Alignment.topCenter,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  GRÁFICA: BARRAS POR CLASE
// ═══════════════════════════════════════════════════════════════════════════════
class _BarChartClase extends StatelessWidget {
  final Map<String, int> datos;

  const _BarChartClase({required this.datos});

  @override
  Widget build(BuildContext context) {
    final entries = datos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxY = entries.isEmpty
    ? 5.0
    : (entries.first.value + 2).toDouble();

    // Colores cíclicos para las barras
    const barColors = [
      [Color(0xFF1B5E20), Color(0xFF81C784)],
      [Color(0xFF0D47A1), Color(0xFF64B5F6)],
      [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
      [Color(0xFFE65100), Color(0xFFFFB74D)],
      [Color(0xFF880E4F), Color(0xFFF48FB1)],
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // CORRECCIÓN: Mapear índice usando group.x de forma segura
              final index = group.x.toInt();
              if (index < 0 || index >= entries.length) {
                return null;
              }

              return BarTooltipItem(
                '${entries[index].key}\n${rod.toY.toInt()} reservas',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (maxY / 4).clamp(1, 999).toDouble(),
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();

                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }

                final nombre = entries[index].key;
                final corto  = nombre.length > 9 ? '${nombre.substring(0, 8)}…' : nombre;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    corto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withAlpha(20),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          entries.length,
          (i) {
            final colors = barColors[i % barColors.length];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.bottomCenter,
                    end:   Alignment.topCenter,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  WIDGETS COMPARTIDOS
// ═══════════════════════════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  final String  valor;
  final String  label;
  final IconData? icono;
  final Color   color;

  const _KpiCard({
    required this.valor,
    required this.label,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color:  Colors.white.withAlpha(22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null)
                Icon(icono, color: color, size: 22)
              else
                Text(valor, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              if (icono != null)
                Text(
                  valor,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: icono != null ? Colors.white60 : color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:  Colors.white.withAlpha(18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final IconData icono;
  final String   texto;
  final Color    color;

  const _SeccionTitulo({required this.icono, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: color, size: 16),
      ),
      const SizedBox(width: 10),
      Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ]);
  }
}

class _FilaClase extends StatelessWidget {
  final String nombre;
  final int    count;
  final int    max;

  const _FilaClase({required this.nombre, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final pct = max == 0 ? 0.0 : count / max;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(nombre,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Text('$count', style: const TextStyle(
              color: Color.fromARGB(255, 44, 81, 110), fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value:            pct,
            minHeight:        7,
            backgroundColor:  Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(
              HSLColor.fromColor(const Color(0xFF64B5F6))
                  .withLightness(0.4 + pct * 0.3)
                  .toColor(),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SinDatos extends StatelessWidget {
  const _SinDatos();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text('Sin datos todavía',
          style: TextStyle(color: Colors.white38, fontSize: 14)),
    ),
  );
}