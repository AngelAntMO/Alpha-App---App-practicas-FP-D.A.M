import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  final List<String> negocios;
  const DashboardPage({super.key, required this.negocios});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    double sizeIcono = min(max(screenWidth * 0.06, 26), 42);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
            ),
          ),
        ),

        title: SizedBox(
          height: 130,
          child: Image.asset(
            'assets/images/LogoAlphaAppPagInicio.png',
            fit: BoxFit.contain,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: sizeIcono),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, size: sizeIcono),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const profile_page()),
              );
            },
          ),
        ],
      ),

      // 👇 SOLO mostramos reservas
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildReservasTab(user, screenWidth),
      ),
    );
  }

  // =========================
  // RESERVAS (SIN CAMBIOS)
  // =========================
  Widget _buildReservasTab(User user, double screenWidth) {
    final reservasQuery = FirebaseFirestore.instance
        .collection('reservas')
        .where('userId', isEqualTo: user.uid)
        .where('estado', isEqualTo: 'activa');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reservasQuery.snapshots(),
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeleton(constraints);
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Text(
                    'No tienes reservas activas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              );
            }

            final reservas = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: reservas.map((doc) {
                    final data = doc.data();
                    final servicio = data['servicio'];
                    final clase = data['clase'];
                    final hora = data['hora'];
                    final fecha = (data['fecha'] as Timestamp).toDate();

                    return Center(
                      child: SizedBox(
                        width: screenWidth > 800
                            ? 500
                            : screenWidth * 0.95,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            title: Text('$servicio'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clase),
                                Text('📅 ${DateFormat('dd/MM/yyyy').format(fecha)}'),
                                Text('⏰ $hora'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar reserva'),
                                    content: const Text('¿Seguro que quieres eliminar esta reserva?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                    HapticFeedback.mediumImpact();
                                    try {
                                      await FirebaseFirestore.instance
                                        .collection('reservas')
                                        .doc(doc.id)
                                        .delete();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Reserva eliminada correctamente'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al eliminar: $e'),
                                        ),
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeleton(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
