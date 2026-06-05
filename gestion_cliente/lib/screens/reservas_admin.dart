import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservasClasePage extends StatefulWidget {
  const ReservasClasePage({super.key});

  @override
  State<ReservasClasePage> createState() => _ReservasClasePageState();
}

class _ReservasClasePageState extends State<ReservasClasePage> {
  String? claseSeleccionada;
  String filtroEstado = 'todas';

  String? _negocioID; 
  bool _cargandoNegocio = true;
  String? _errorNegocio;

  late Future<QuerySnapshot> _clasesFuture;

  // Cache en memoria para evitar llamadas duplicadas a la colección de usuarios
  final Map<String, Map<String, dynamic>> _usuariosCache = {};

  @override
  void initState() {
    super.initState();
    _inicializarPagina();
  }

  Future<void> _inicializarPagina() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorNegocio = 'Usuario no autenticado';
          _cargandoNegocio = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        setState(() {
          _errorNegocio = 'Datos de usuario no encontrados en la base de datos';
          _cargandoNegocio = false;
        });
        return;
      }

      final data = doc.data();
      String? negocioID;

      // Usamos 'negocios' en plural como me confirmaste
      final campoNegocio = data?['negocios'];

      if (campoNegocio is List) {
        if (campoNegocio.isNotEmpty) {
          negocioID = campoNegocio.first.toString().trim();
        }
      } else if (campoNegocio != null) {
        negocioID = campoNegocio.toString().trim();
      }

      if (negocioID == null || negocioID.isEmpty) {
        setState(() {
          _errorNegocio = 'El usuario existe, pero el campo "negocios" está vacío o no se encuentra.';
          _cargandoNegocio = false;
        });
        return;
      }

      setState(() {
        _negocioID = negocioID; 
        // Buscamos las clases (aquí mantengo negocioID, si tu colección 'clases' también usa negocioNombre, cámbialo aquí abajo)
        _clasesFuture = FirebaseFirestore.instance
            .collection('clases')
            .where('negocioID', isEqualTo: negocioID)
            .get();
        _cargandoNegocio = false;
      });
    } catch (e) {
      setState(() {
        _errorNegocio = 'Error al cargar datos del negocio: $e';
        _cargandoNegocio = false;
      });
    }
  }

  Future<void> borrarFinalizadas() async {
    if (claseSeleccionada == null || _negocioID == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('reservas')
          .where('negocioNombre', isEqualTo: _negocioID) // <--- CAMBIADO A negocioNombre
          .where('claseNombre', isEqualTo: claseSeleccionada)
          .where('estado', isEqualTo: 'finalizada') 
          .get();

      if (query.docs.isEmpty) {
        if (!mounted) return;
        _showSnack('No hay reservas finalizadas');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (!mounted) return;
      _showSnack('${query.docs.length} reservas eliminadas');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<Map<String, dynamic>> _obtenerDatosUsuario(String userId) async {
    if (_usuariosCache.containsKey(userId)) {
      return _usuariosCache[userId]!;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data() ?? {
      'nombre': 'Usuario',
      'apellidos': 'eliminado',
      'telefono': '',
      'email': ''
    };
    
    _usuariosCache[userId] = data; 
    return data;
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
        body: _cargandoNegocio
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorNegocio != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _errorNegocio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            /// SELECTOR DE CLASES
                            FutureBuilder<QuerySnapshot>(
                              future: _clasesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Center(child: SelectableText('ERROR:\n${snapshot.error}'));
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Text('No hay clases disponibles', style: TextStyle(color: Colors.white));
                                }

                                final clases = snapshot.data!.docs;

                                return DropdownButtonFormField<String>(
                                  initialValue: claseSeleccionada,
                                  decoration: _buildInputDecoration('Selecciona una clase'),
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
                                  onTap: () => setState(() => filtroEstado = 'finalizadas'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: () async {
                                final confirm = await _mostrarDialogoConfirmacion();
                                if (confirm == true) {
                                  borrarFinalizadas();
                                }
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.lightBlueAccent),
                              label: const Text('Borrar finalizadas', style: TextStyle(color: Colors.white)),
                              style: _buildBotondeBorradoStyle(),
                            ),
                            const SizedBox(height: 10),

                            /// LISTA DE RESERVAS
                            if (claseSeleccionada != null)
                              Flexible(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('reservas')
                                      .where('negocioNombre', isEqualTo: _negocioID) // <--- CAMBIADO A negocioNombre
                                      .where('claseNombre', isEqualTo: claseSeleccionada)
                                      .orderBy('fechaHora')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No hay reservas para esta clase',
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                        ),
                                      );
                                    }

                                    final reservas = snapshot.data!.docs.where((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      final estado = data['estado'] ?? '';
                                      if (filtroEstado == 'todas') return true;
                                      if (filtroEstado == 'activas') return estado != 'finalizada';
                                      return estado == 'finalizada';
                                    }).toList();

                                    if (reservas.isEmpty) {
                                      return const Center(child: Text('No hay reservas con este filtro', style: TextStyle(color: Colors.white70)));
                                    }

                                    return ListView.builder(
                                      itemCount: reservas.length,
                                      itemBuilder: (context, index) {
                                        final resDoc = reservas[index];
                                        final reserva = resDoc.data() as Map<String, dynamic>;
                                        final userId = reserva['userId'] ?? '';

                                        return FutureBuilder<Map<String, dynamic>>(
                                          future: _obtenerDatosUsuario(userId),
                                          builder: (context, userSnapshot) {
                                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Card(
                                                color: Colors.white10,
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text('Cargando datos de usuario...', style: TextStyle(color: Colors.white70)),
                                                ),
                                              );
                                            }

                                            final user = userSnapshot.data!;
                                            final nombre = user['nombre'] ?? '';
                                            final apellidos = user['apellidos'] ?? '';
                                            final telefono = user['telefono'] ?? '';
                                            final email = user['email'] ?? '';

                                            final estado = reserva['estado'] ?? '';
                                            final hora = reserva['hora'] ?? '';
                                            final fechaTimestamp = reserva['fechaHora'] as Timestamp?;
                                            final fecha = fechaTimestamp?.toDate() ?? DateTime.now();

                                            return ReservaCard(
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                padding: const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CircleAvatar(
                                                      radius: 22,
                                                      backgroundColor: Colors.transparent,
                                                      child: Icon(Icons.person, color: Colors.lightBlueAccent),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '$nombre $apellidos',
                                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                                          ),
                                                          const SizedBox(height: 6),
                                                          Text('📧 $email', style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
                                                          Text('📞 $telefono', style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
                                                          const SizedBox(height: 6),
                                                          Text('🕒 $hora', style: const TextStyle(color: Colors.lightBlueAccent)),
                                                          Text('📅 ${fecha.day}/${fecha.month}/${fecha.year}', style: const TextStyle(color: Colors.lightBlueAccent)),
                                                          const SizedBox(height: 6),
                                                          _buildEstadoBadge(estado),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      tooltip: 'Eliminar reserva',
                                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                      onPressed: () => _eliminarReservaIndividual(resDoc.reference),
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

  // --- MÉTODOS AUXILIARES DE INTERFAZ ---

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
      ),
    );
  }

  ButtonStyle _buildBotondeBorradoStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent.withValues(alpha: 0.25),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    final isFinalizada = estado == 'finalizada';
    final color = isFinalizada ? Colors.amber : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: isFinalizada ? Colors.amberAccent : Colors.greenAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text('¿Eliminar reservas finalizadas?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.lightBlueAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarReservaIndividual(DocumentReference ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Eliminar reserva', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar esta reserva?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.delete();
        _showSnack('Reserva eliminada');
      } catch (e) {
        _showSnack('Error: $e');
      }
    }
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
        child: widget.child,
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
          color: selected ? Colors.lightBlueAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.lightBlueAccent : Colors.white.withValues(alpha: 0.15),
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