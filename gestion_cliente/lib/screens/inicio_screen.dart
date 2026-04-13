// (IMPORTS IGUALES QUE TENÍAS)
import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
import 'package:gestion_cliente/screens/reserva_screen.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  State<PaginaInicio> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio>
    with SingleTickerProviderStateMixin {

  late AnimationController _logoController;
  late Animation<double> _logoAnim;

  bool _isLoadingDashboard = false;

  List<String> _negocios = [];
  final Map<String, bool> _hoveringServicios = {};

  final Map<String, String> rutasServicios = const {
    'Gimnasio': '/gimnasio',
    'Centro de Yoga': '/yoga',
    'Peluqueria': '/peluqueria',
    'Centro de Fisioterapia': '/fisioterapia',
    'Academia': '/academia',
  };

  @override
  void initState() {
    super.initState();
    _cargarNegocios();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnim = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);

    _logoController.repeat(reverse: true);
  }

  Future<void> _cargarNegocios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final negocios = List<String>.from(data['negocios'] ?? []);

        setState(() {
          _negocios = negocios;
          for (var n in negocios) {
            _hoveringServicios[n] = false;
          }
        });
      }
    }
  }

  IconData getIcono(String negocio) {
    switch (negocio) {
      case 'Gimnasio':
        return Icons.fitness_center;
      case 'Centro de Yoga':
        return Icons.self_improvement;
      case 'Peluqueria':
        return Icons.content_cut;
      case 'Centro de Fisioterapia':
        return Icons.health_and_safety;
      case 'Academia':
        return Icons.school;
      default:
        return Icons.business;
    }
  }

  Widget buildAnimatedServiceCard(String negocio, double width) {
    final isHovering = _hoveringServicios[negocio] ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveringServicios[negocio] = true),
      onExit: (_) => setState(() => _hoveringServicios[negocio] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isHovering ? -8 : 0, 0),
        width: width,
        child: Material(
          color: Colors.white,
          elevation: isHovering ? 10 : 4,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final ruta = rutasServicios[negocio];
              if (ruta != null) {
                Navigator.pushNamed(context, ruta);
              }
            },
            child: ListTile(
              leading: Icon(getIcono(negocio)),
              title: Text(negocio),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 100,
          title: SizedBox(
            height: 80,
            child: Image.asset('assets/images/LogoAlphaAppPagInicio.png'),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReservaPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const profile_page()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: _irAlDashboard,
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              children: [

                // LOGO (igual que tenías)
                Center(
                  child: AnimatedBuilder(
                    animation: _logoAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnim.value,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/LogoAlphaAppPagInicio.png',
                      width: screenWidth * 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // SERVICIOS
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: _negocios.map((negocio) {
                    return buildAnimatedServiceCard(
                      negocio,
                      screenWidth > 900 ? 500 : screenWidth * 0.9,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _irAlDashboard() async {
    setState(() => _isLoadingDashboard = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() as Map<String, dynamic>;
      List<String> negocios = List<String>.from(data['negocios'] ?? []);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(negocios: negocios),
        ),
      );
    }

    setState(() => _isLoadingDashboard = false);
  }
}
