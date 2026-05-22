import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class WorkerCheckScreen extends StatefulWidget {
  const WorkerCheckScreen({super.key});

  @override
  State<WorkerCheckScreen> createState() => _WorkerCheckScreenState();
}

class _WorkerCheckScreenState extends State<WorkerCheckScreen>
    with SingleTickerProviderStateMixin {

  final user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool isWorking = false;

  String name = "";
  String surname = "";
  String clase = "";

  double weeklyHours = 0;

  bool showHistory = false;
    List<Map<String, dynamic>> monthlyHistory = [];

  DateTime? checkInTime;
  Duration workedLive = Duration.zero;

  int selectedYear = DateTime.now().year;

  static const int maxHoursLimit = 10;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Ticker((_) {
      if (isWorking && checkInTime != null) {
        final DateTime now = DateTime.now();
        final Duration difference = now.difference(checkInTime!);

          if (difference.inHours >= maxHoursLimit) {
          _ticker.stop(); // Detenemos el ticker para evitar bucles
          checkOut(); 
        } else {
          setState(() {
            workedLive = difference;
          });
        }
      }
    });

    _ticker.start();

    init();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> init() async {
    await Future.wait([
      loadUser(),
      loadCurrentStatus(),
      loadWeeklyHours(),
    ]);
  
    setState(() => isLoading = false);
  }

  // ─────────────────────────────────────────────
  // USER
  // ─────────────────────────────────────────────
  Future<void> loadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    name = doc.data()?['nombre'] ?? "";
    surname = doc.data()?['apellidos'] ?? "";
    clase = doc.data()?['clase'] ?? "";
  }

  // ─────────────────────────────────────────────
  // STATUS
  // ─────────────────────────────────────────────
  Future<void> loadCurrentStatus() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

   if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final dynamic data = doc.data(); // Obtenemos el data de forma segura
      
      if (data['checkIn'] != null) {
        final DateTime startTime = (data['checkIn'] as Timestamp).toDate();
        final Duration diff = DateTime.now().difference(startTime);

      //Si al abrir la app detectamos que ya pasaron más de 10 horas
      if (diff.inHours >= maxHoursLimit) {
        await forceCheckOutAtLimit(doc.reference, startTime);
        isWorking = false;
        checkInTime = null;
        workedLive = Duration.zero;
      } else {
        isWorking = true;
        checkInTime = startTime;
        workedLive = diff;
        }
      }
    } else {
      isWorking = false;
      checkInTime = null;
      workedLive = Duration.zero;
    }

    if (mounted) setState(() {});
  }

  Future<void> forceCheckOutAtLimit(DocumentReference docRef, DateTime start) async {
    final limitTime = start.add(const Duration(hours: maxHoursLimit));
    await docRef.update({
      'checkOut': Timestamp.fromDate(limitTime),
      'status': 'closed',
      'workedHours': maxHoursLimit.toDouble(),
      'autoClosed': true,
    });
  }

  // ─────────────────────────────────────────────
  // CHECK IN
  // ─────────────────────────────────────────────
  Future<void> checkIn() async {
    try {
      HapticFeedback.mediumImpact();

    final existing = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await FirebaseFirestore.instance.collection('time_logs').add({
      'employeeId': user!.uid,
      'clase': clase,
      'checkIn': Timestamp.now(),
      'status': 'open',
    });

    if (!_ticker.isTicking) _ticker.start();
    await loadCurrentStatus();
    } catch (e) {
      _showErrorSnackBar("Error al fichar entrada");
    }
  }

  Future<void> confirmCheckOut() async {
    // Un detalle "Top" es pedir confirmación para no fichar salida por error
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Finalizar jornada?"),
        content: const Text("Se registrará tu salida actual."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("SÍ, FINALIZAR")),
        ],
      ),
    );

    if (confirm == true) {
      await checkOut();
    }
  }
  // ─────────────────────────────────────────────
  // CHECK OUT
  // ─────────────────────────────────────────────
  Future<void> checkOut() async {
    try {
      HapticFeedback.heavyImpact();

    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final doc = query.docs.first;
    final DateTime checkInDate = (doc['checkIn'] as Timestamp).toDate();
    final DateTime now = DateTime.now();

    Duration diff = now.difference(checkInDate);

    if (diff.inHours >= maxHoursLimit) {
      diff = const Duration(hours: maxHoursLimit);
    }

    final double hours = diff.inMinutes / 60;

    if (hours < 0.016) { 
        await doc.reference.delete();
      } else {
        await doc.reference.update({
          'checkOut': diff.inHours >= maxHoursLimit
              ? Timestamp.fromDate(checkInDate.add(const Duration(hours: maxHoursLimit)))
              : FieldValue.serverTimestamp(),
          'status': 'closed',
          'workedHours': hours,
        });
      }

      if (!mounted) return;

    await Future.wait([
      loadCurrentStatus(),
      loadWeeklyHours(),
    ]);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Jornada registrada correctamente")),
        );
      } catch (e) {
        _showErrorSnackBar("Error al registrar salida");
      }
    }

    // Función auxiliar para errores
    void _showErrorSnackBar(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

  // ─────────────────────────────────────────────
  // WEEKLY HOURS
  // ─────────────────────────────────────────────
  Future<void> loadWeeklyHours() async {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.subtract(Duration(days: now.weekday - 1)).year,
      now.subtract(Duration(days: now.weekday - 1)).month,
      now.subtract(Duration(days: now.weekday - 1)).day,
    );

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('checkIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('checkIn', isLessThan: Timestamp.fromDate(endOfWeek))
        .get();

    double total = 0;

    for (var doc in query.docs) {
      final data = doc.data();
      if (data.containsKey('workedHours')) {
        total += (data['workedHours'] as num).toDouble();
      }
    }

    weeklyHours = total;

    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────
  // HISTORY (ESCALABLE)
  // ─────────────────────────────────────────────
  Future<void> loadMonthlyHistory() async {
    final query = await FirebaseFirestore.instance
      .collection('time_logs')
      .where('employeeId', isEqualTo: user!.uid)
      .get();

  // Mapa para acumular horas: { "1": 160.5, "2": 140.0 ... }
  Map<int, double> months = {};

  for (var doc in query.docs) {
    final data = doc.data();
    if (!data.containsKey('workedHours')) continue;

    final date = (data['checkIn'] as Timestamp).toDate();
    if (date.year != selectedYear) continue;

    // Agrupamos por el número del mes
    months[date.month] = (months[date.month] ?? 0) + (data['workedHours'] as num).toDouble();
  }

  // Convertimos el mapa en una lista ordenada para la UI
  monthlyHistory = months.entries.map((e) {
    return {
      'month': e.key,
      'hours': e.value,
    };
  }).toList();

  // Ordenar de mes más reciente a más antiguo
  monthlyHistory.sort((a, b) => (b['month'] as int).compareTo(a['month'] as int));

  if (mounted) setState(() {});
}

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E293B),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("⏱ Fichaje trabajador"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    Text(
                      "👋 $name $surname",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _toggle(),

                    const SizedBox(height: 20),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: showHistory ? _history() : _main(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _toggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab("Resumen", !showHistory),
        const SizedBox(width: 10),
        _tab("Historial", showHistory),
      ],
    );
  }

  Widget _tab(String text, bool active) {
    return GestureDetector(
      onTap: () async {
        setState(() => showHistory = text == "Historial");

        if (showHistory) {
          await loadMonthlyHistory();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _main() {

    Color timerColor = Colors.white;
    if (workedLive.inHours >= 9) timerColor = Colors.orangeAccent;
    if (workedLive.inHours >= maxHoursLimit) timerColor = Colors.redAccent;

    return Column(
      children: [

        // ESTADO
        Text(
          isWorking ? "🟢 Trabajando" : "🔴 No fichado",
          style: const TextStyle(color: Colors.white),
        ),

        const SizedBox(height: 10),

        // RELOJ EN VIVO
        if (isWorking && checkInTime != null)
          Column(
            children: [
              Text(
                "⏱ ${_formatDuration(workedLive)}",
                style: TextStyle(
                  fontSize: 28,
                  color: timerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Tiempo trabajado (Máx 10h)",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // BOTÓN
        SizedBox(
          width: 260,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isWorking ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: isWorking ? confirmCheckOut : checkIn,
            child: Text(
              isWorking ? "FICHAR SALIDA" : "FICHAR ENTRADA",
            ),
          ),
        ),

        const SizedBox(height: 20),

        // HORAS SEMANA
        _card(
          Column(
            children: [
              const Text("📅 Horas semanales",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                "${weeklyHours.toStringAsFixed(2)} h",
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _history() {
    // Lista de nombres de meses para mostrar
  const monthNames = [
    "", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  return Column(
    children: [
      // Selector de año
      DropdownButton<int>(
        value: selectedYear,
        dropdownColor: const Color(0xFF1E293B),
        style: const TextStyle(color: Colors.white),
        items: List.generate(5, (i) => DateTime.now().year - i)
            .map((year) => DropdownMenuItem(value: year, child: Text("📅 $year")))
            .toList(),
        onChanged: (val) async {
          if (val == null) return;
          setState(() => selectedYear = val);
          await loadMonthlyHistory();
        },
      ),

      const SizedBox(height: 10),

      if (monthlyHistory.isEmpty)
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No hay registros este año", style: TextStyle(color: Colors.white70)),
        ),

      Expanded(
        child: ListView.builder(
          itemCount: monthlyHistory.length,
          itemBuilder: (_, i) {
            final m = monthlyHistory[i];
            final monthName = monthNames[m['month'] as int];

            return _card(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Total del mes",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      "${(m['hours'] as double).toStringAsFixed(1)}h",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

  // ─────────────────────────────────────────────
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    return "${h.toString().padLeft(2, '0')}:"
        "${m.toString().padLeft(2, '0')}:"
        "${s.toString().padLeft(2, '0')}";
  }
}
