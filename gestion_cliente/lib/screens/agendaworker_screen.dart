import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AgendaWorkerPage extends StatefulWidget {
  const AgendaWorkerPage({super.key});
  
   @override
  
  State<AgendaWorkerPage> createState() => _AgendaWorkerPageState();
}

  bool _hasNewReservas = false;
  int _previousCount = 0;

class _AgendaWorkerPageState extends State<AgendaWorkerPage> {
  int _previousCount = 0;

final user = FirebaseAuth.instance.currentUser;

  Stream<List<String>> getClasesDelEmpleado() {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  return FirebaseFirestore.instance
      .collection('reservas')
      .where('employeeID', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
}


Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Scaffold(
      body: Center(child: Text('Usuario no autenticado')),
    );
  }

  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Mis Reservas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<List<String>>(
  stream: getClasesDelEmpleado(),
  builder: (context, clasesSnapshot) {

    if (!clasesSnapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final claseNombre = clasesSnapshot.data!;

    if (claseNombre.isEmpty) {
      return const Center(
        child: Text(
          'No tienes clases asignadas',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservas')
          .where('employeeID', isEqualTo: user!.uid.trim())
          .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservas = snapshot.data!.docs;

          if (_previousCount != 0 && reservas.length > _previousCount) {
          _hasNewReservas = true;
      }

          if (reservas.length > _previousCount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Nueva reserva recibida 📅'),
            backgroundColor: Colors.green,
        ),
      );
    });
  }

_previousCount = reservas.length;

          if (reservas.isEmpty) {
            return const Center(
              child: Text(
                'No hay reservas',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final data =
                  reservas[index].data() as Map<String, dynamic>;

              final Timestamp ts = data['fecha'];
              final DateTime fecha = ts.toDate();

              final String cliente =
                  data['cliente'] ?? 'Usuario desconocido';
              final String clase = data['claseNombre'] ?? '';
              final String hora = data['hora'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Row(
                        children: [
                          // 📅 FECHA CIRCULAR (igual estética worker)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${fecha.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${fecha.month}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // 📄 INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  clase,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.blueAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      hora,
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white38,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
  }
    ),
  )
  );
}
}