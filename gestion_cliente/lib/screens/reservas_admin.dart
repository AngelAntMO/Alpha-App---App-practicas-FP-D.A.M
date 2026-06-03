import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservasClasePage extends StatefulWidget {
  final String negocioID;

  const ReservasClasePage({super.key, required this.negocioID});

  @override
  State<ReservasClasePage> createState() => _ReservasClasePageState();
}

class _ReservasClasePageState extends State<ReservasClasePage> {
  String? claseSeleccionada;
  String filtroEstado = 'todas';

  Future<void> borrarFinalizadas() async {
    if (claseSeleccionada == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('reservas')
          .where('claseNombre', isEqualTo: claseSeleccionada)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var doc in query.docs) {
        final data = doc.data();

        if (data['estado'] == 'finalizada') {
          batch.delete(doc.reference);
          count++;
        }
      }

      await batch.commit();

      if (!mounted) return;

      _showSnack(
        count == 0
            ? 'No hay reservas finalizadas'
            : '$count reservas eliminadas',
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Reservas por clase',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  /// SELECTOR DE CLASES
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('clases')
                        .where('negocioID', isEqualTo: widget.negocioID)
                        .get(),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        debugPrint("ERROR FIREBASE: ${snapshot.error}");

                        return Center(
                          child: SelectableText('ERROR:\n${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No hay clases disponibles');
                      }

                      final clases = snapshot.data!.docs;

                      return DropdownButtonFormField<String>(
                        initialValue: claseSeleccionada,

                        decoration: InputDecoration(
                          labelText: 'Selecciona una clase',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.lightBlueAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1E293B),
                        iconEnabledColor: Colors.lightBlueAccent,

                        items: clases.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final nombre = data['nombre'] ?? '';

                          return DropdownMenuItem<String>(
                            value: nombre,
                            child: Text(nombre),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            claseSeleccionada = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    children: [
                      _FiltroButton(
                        label: 'Todas',
                        selected: filtroEstado == 'todas',
                        onTap: () => setState(() => filtroEstado = 'todas'),
                      ),
                      _FiltroButton(
                        label: 'Activas',
                        selected: filtroEstado == 'activas',
                        onTap: () => setState(() => filtroEstado = 'activas'),
                      ),
                      _FiltroButton(
                        label: 'Finalizadas',
                        selected: filtroEstado == 'finalizadas',
                        onTap: () =>
                            setState(() => filtroEstado = 'finalizadas'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1E293B),
                          title: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            '¿Eliminar reservas finalizadas?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.lightBlueAccent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        borrarFinalizadas();
                      }
                    },

                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.lightBlueAccent,
                    ),
                    label: const Text(
                      'Borrar finalizadas',
                      style: TextStyle(color: Colors.white),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.25),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LISTA DE RESERVAS
                  if (claseSeleccionada != null)
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reservas')
                            .where('claseNombre', isEqualTo: claseSeleccionada)
                            .orderBy('fechaHora')
                            .snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay reservas para esta clase',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          final allReservas = snapshot.data!.docs;

                          final reservas = allReservas.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final estado = data['estado'];

                            if (filtroEstado == 'todas') return true;
                            if (filtroEstado == 'activas') {
                              return estado != 'finalizada';
                            }
                            if (filtroEstado == 'finalizadas') {
                              return estado == 'finalizada';
                            }

                            return true;
                          }).toList();

                          return ListView.builder(
                            itemCount: reservas.length,

                            itemBuilder: (context, index) {
                              final reserva =
                                  reservas[index].data()
                                      as Map<String, dynamic>;

                              final userId = reserva['userId'];

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .get(),

                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ListTile(
                                      title: Text('Cargando usuario...'),
                                    );
                                  }

                                  final user =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>?;

                                  final nombre =
                                      user?['nombre'] ?? 'Usuario eliminado';
                                  final apellidos = user?['apellidos'] ?? '';
                                  final telefono = user?['telefono'] ?? '';
                                  final email = user?['email'] ?? '';

                                  final estado = reserva['estado'] ?? '';
                                  final hora = reserva['hora'] ?? '';

                                  final fechaTimestamp =
                                      reserva['fechaHora'] as Timestamp;
                                  final fecha = fechaTimestamp.toDate();

                                  return ReservaCard(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),

                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.transparent,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$nombre $apellidos',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  '📧 $email',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.75,
                                                        ),
                                                  ),
                                                ),

                                                Text(
                                                  '📞 $telefono',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.75,
                                                        ),
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  '🕒 $hora',
                                                  style: const TextStyle(
                                                    color:
                                                        Colors.lightBlueAccent,
                                                  ),
                                                ),

                                                Text(
                                                  '📅 ${fecha.day}/${fecha.month}/${fecha.year}',
                                                  style: const TextStyle(
                                                    color:
                                                        Colors.lightBlueAccent,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        estado == 'finalizada'
                                                        ? Colors.amber
                                                              .withValues(
                                                                alpha: 0.15,
                                                              )
                                                        : Colors.green
                                                              .withValues(
                                                                alpha: 0.15,
                                                              ),

                                                    border: Border.all(
                                                      color:
                                                          estado == 'finalizada'
                                                          ? Colors.amber
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                )
                                                          : Colors.green
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    estado,
                                                    style: TextStyle(
                                                      color:
                                                          estado == 'finalizada'
                                                          ? Colors.amberAccent
                                                          : Colors.greenAccent,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Eliminar reserva',

                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),

                                            onPressed: () async {
                                              final confirm = await showDialog(
                                                context: context,

                                                builder: (_) => AlertDialog(
                                                  backgroundColor: const Color(
                                                    0xFF1E293B,
                                                  ),

                                                  title: const Text(
                                                    'Eliminar reserva',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),

                                                  content: const Text(
                                                    '¿Seguro que quieres eliminar esta reserva?',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),

                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),

                                                      child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),

                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),

                                                      child: const Text(
                                                        'Eliminar',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await reservas[index]
                                                      .reference
                                                      .delete();

                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Reserva eliminada',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
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

class ReservaCard extends StatefulWidget {
  final Widget child;

  const ReservaCard({super.key, required this.child});

  @override
  State<ReservaCard> createState() => _ReservaCardState();
}

class _ReservaCardState extends State<ReservaCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _FiltroButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FiltroButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.lightBlueAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.lightBlueAccent
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.lightBlueAccent : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
