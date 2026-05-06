import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  List<Map<String, dynamic>> weeklyHistory = [];

  DateTime? checkInTime;
  Duration workedLive = Duration.zero;

  int selectedYear = DateTime.now().year;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Ticker((_) {
      if (isWorking && checkInTime != null) {
        setState(() {
          workedLive = DateTime.now().difference(checkInTime!);
        });
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

    isWorking = query.docs.isNotEmpty;

    if (isWorking) {
      final doc = query.docs.first;
      checkInTime = (doc['checkIn'] as Timestamp).toDate();
    } else {
      checkInTime = null;
      workedLive = Duration.zero;
    }

    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────
  // CHECK IN
  // ─────────────────────────────────────────────
  Future<void> checkIn() async {
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

    await loadCurrentStatus();
  }

  // ─────────────────────────────────────────────
  // CHECK OUT
  // ─────────────────────────────────────────────
  Future<void> checkOut() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final doc = query.docs.first;

    final checkIn = (doc['checkIn'] as Timestamp).toDate();
    final diff = DateTime.now().difference(checkIn);

    final hours = diff.inMinutes / 60;

    if (hours < 0.02) {
      await doc.reference.delete();
      await loadCurrentStatus();
      return;
    }

    await doc.reference.update({
      'checkOut': FieldValue.serverTimestamp(),
      'status': 'closed',
      'workedHours': hours,
    });

    await Future.wait([
      loadCurrentStatus(),
      loadWeeklyHours(),
    ]);
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
  Future<void> loadWeeklyHistory() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .get();

    Map<DateTime, double> weeks = {};

    for (var doc in query.docs) {
      final data = doc.data();
      if (!data.containsKey('workedHours')) continue;

      final date = (data['checkIn'] as Timestamp).toDate();

      if (date.year != selectedYear) continue;

      final startOfWeek = DateTime(
        date.subtract(Duration(days: date.weekday - 1)).year,
        date.subtract(Duration(days: date.weekday - 1)).month,
        date.subtract(Duration(days: date.weekday - 1)).day,
      );

      weeks[startOfWeek] =
          (weeks[startOfWeek] ?? 0) +
          (data['workedHours'] as num).toDouble();
    }

    weeklyHistory = weeks.entries.map((e) {
      return {
        'start': e.key,
        'end': e.key.add(const Duration(days: 6)),
        'hours': e.value,
      };
    }).toList();

    weeklyHistory.sort((a, b) =>
        (b['start'] as DateTime).compareTo(a['start'] as DateTime));

    setState(() {});
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
          await loadWeeklyHistory();
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
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Tiempo trabajado",
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
            onPressed: isWorking ? checkOut : checkIn,
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
    return Column(
      children: [

        // AÑO
        DropdownButton<int>(
          value: selectedYear,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          items: List.generate(5, (i) {
            final year = DateTime.now().year - i;
            return DropdownMenuItem(
              value: year,
              child: Text("📅 $year"),
            );
          }),
          onChanged: (val) async {
            setState(() => selectedYear = val!);
            await loadWeeklyHistory();
          },
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: weeklyHistory.length,
            itemBuilder: (_, i) {
              final w = weeklyHistory[i];

              return _card(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📆 ${(w['start'] as DateTime).day}/${(w['start'] as DateTime).month} - "
                      "${(w['end'] as DateTime).day}/${(w['end'] as DateTime).month}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "⏱ ${(w['hours'] as double).toStringAsFixed(1)}h",
                      style: const TextStyle(color: Colors.white),
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
