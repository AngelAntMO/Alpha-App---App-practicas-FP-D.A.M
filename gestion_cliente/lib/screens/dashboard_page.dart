import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/servicios/academia_page.dart';
import 'package:gestion_cliente/screens/servicios/fisioterapia_page.dart';
import 'package:gestion_cliente/screens/servicios/gimnasio_page.dart';
import 'package:gestion_cliente/screens/servicios/peluqueria_page.dart';
import 'package:gestion_cliente/screens/servicios/yoga_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';


class DashboardPage extends StatefulWidget {
  final List<String> negocios;
  const DashboardPage({super.key, required this.negocios});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  // 1. MAPA DE FACTORÍA: Asocia el nombre con el Widget de destino
  final Map<String, Widget Function(String uid, String nombre)> paginasServicios = {
    'Gimnasio': (uid, nombre) => GimnasioPage(userId: uid, negocio: nombre),
    'Yoga': (uid, nombre) => YogaPage(userId: uid, negocio: nombre),
    'Peluqueria': (uid, nombre) => PeluqueriaPage(userId: uid, negocio: nombre),
    'Fisioterapia': (uid, nombre) => FisioterapiaPage(userId: uid, negocio: nombre),
    'Academia': (uid, nombre) => AcademiaPage(userId: uid, negocio: nombre), // O el widget que uses
  };

  final Map<String, bool> _hoveringServicios = {};
  final Map<String, bool> _pressedServicios = {};

  // 2. FUNCIÓN PARA NAVEGAR SIN CAMBIAR LA URL

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });

    for (var n in widget.negocios) {
      _hoveringServicios[n] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData getIcono(String negocio) {
    switch (negocio) {
      case 'Gimnasio': return Icons.fitness_center;
      case 'Yoga': return Icons.self_improvement;
      case 'Peluqueria': return Icons.content_cut;
      case 'Fisioterapia': return Icons.health_and_safety;
      case 'Academia': return Icons.school;
      default: return Icons.business;
    }
  }

  Widget buildAnimatedServiceCard(String negocio, double width) {
    final isHovering = _hoveringServicios[negocio] ?? false;
    final isPressed = _pressedServicios[negocio] ?? false;

  return StatefulBuilder(
    builder: (context, setLocalState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveringServicios[negocio] = true),
        onExit: (_) => setState(() => _hoveringServicios[negocio] = false),
        child: GestureDetector(
         onTapDown: (_) => setState(() {
  _pressedServicios[negocio] = true;
}),

onTapUp: (_) => setState(() {
  _pressedServicios[negocio] = false;
}),

onTapCancel: () => setState(() {
  _pressedServicios[negocio] = false;
}),
          onTap: () {
  final builder = paginasServicios[negocio];

  if (builder != null) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final pagina = builder(uid, negocio);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => pagina,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
},
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(
                0,
                isHovering ? -6 : 0,
                0,
              ),
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHovering
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF64B5F6)
                            .withValues(alpha: 0.15),
                        child: Icon(
                          getIcono(negocio),
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                      title: Text(
                        negocio,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    double sizeIcono = min(max(screenWidth * 0.06, 26), 42);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
        ),
        title: SizedBox(
          height: 120,
          child: Image.asset('assets/images/LogoAlphaAppPagInicio.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: sizeIcono, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicePage())),
          ),

        ],
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha:0.15),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'Servicios'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _currentIndex == 0
                  ? _buildServiciosTab(user, screenWidth)
                  : _buildReservasTab(user, screenWidth),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiciosTab(User user, double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Column(
                  children: [
                    FloatingHand(),
                    SizedBox(height: 10),
                    Text('Bienvenido/a', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          // AQUÍ SE GENERAN LAS TARJETAS DINÁMICAMENTE
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: widget.negocios.map((n) {
              return buildAnimatedServiceCard(n, screenWidth > 800 ? 300 : screenWidth * 0.95);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReservasTab(User user, double screenWidth) {
    final reservasQuery = FirebaseFirestore.instance
        .collection('reservas')
        .where('userId', isEqualTo: user.uid)
        .where('estado', isEqualTo: 'activa');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reservasQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)));
        final reservas = snapshot.data!.docs;
        if (reservas.isEmpty) return const Center(child: Text('No tienes reservas activas', style: TextStyle(color: Colors.white)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            final data = reservas[index].data();
            final docId = reservas[index].id;
            return Center(
              child: SizedBox(
                width: screenWidth > 800 ? 500 : screenWidth * 0.95,
                child: Card(
                  color: const Color(0xFF93C5FD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    title: Text('${data['negocioNombre']}'),
                    subtitle: Text('${data['claseNombre']}\n📅 ${DateFormat('dd/MM/yyyy').format((data['fecha'] as Timestamp).toDate())}\n⏰ ${data['hora']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarEliminacion(docId),
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

  Future<void> _confirmarEliminacion(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reserva'),
        content: const Text('¿Seguro que quieres eliminar esta reserva?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();
      await FirebaseFirestore.instance.collection('reservas').doc(docId).delete();
    }
  }
}

// Widget FloatingHand se mantiene igual al tuyo
class FloatingHand extends StatefulWidget {
  const FloatingHand({super.key});
  @override
  State<FloatingHand> createState() => _FloatingHandState();
}

class _FloatingHandState extends State<FloatingHand> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _moveAnim = Tween<double>(begin: -6, end: 6).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateAnim = Tween<double>(begin: -0.25, end: 0.25).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(_moveAnim.value, 0),
        child: Transform.rotate(angle: _rotateAnim.value, child: child),
      ),
      child: const Icon(Icons.waving_hand, size: 40, color: Color(0xFF64B5F6)),
    );
  }
} 