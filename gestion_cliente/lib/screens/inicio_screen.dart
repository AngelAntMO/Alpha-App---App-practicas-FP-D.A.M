import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';

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

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);

    _logoController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _irAlDashboard() async {
    setState(() => _isLoadingDashboard = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          List<String> negocios = List<String>.from(data['negocios'] ?? []);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(negocios: negocios),
              ),
            );
          }
        } else {
          _mostrarMensaje("No se encontró tu perfil de usuario.");
        }
      }
    } catch (e) {
      _mostrarMensaje("Error al cargar datos: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Tamaños adaptativos
    double logoSize = screenWidth < 600 ? screenWidth * 0.6 : 300;
    double iconSize = min(max(screenWidth * 0.06, 24), 35);

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
          elevation: 0,
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          leadingWidth: 150,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/images/Icono_AlphaApp.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- SECCIÓN HERO ---
              SizedBox(
                height: screenHeight * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _logoAnim,
                      builder: (context, child) =>
                          Transform.scale(scale: _logoAnim.value, child: child),
                      child: Image.asset(
                        'assets/images/LogoAlphaAppPagInicio.png',
                        width: logoSize,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('Bienvenido a AlphaApp'),
                          TypewriterAnimatedText('Gestión inteligente'),
                          TypewriterAnimatedText('Tu negocio bajo control'),
                        ],
                        repeatForever: true,
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECCIÓN DE TARJETAS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Accesos rápidos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1.1,
                        children: [
                          _buildQuickCard(
                            Icons.calendar_month,
                            "Mi Agenda",
                            _irAlDashboard,
                            isLoading: _isLoadingDashboard,
                          ),
                          _buildQuickCard(
                            Icons.info_outline,
                            "Servicios",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ServicePage(),
                              ),
                            ),
                          ),
                          _buildQuickCard(
                            Icons.person_outline,
                            "Mi Perfil",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    bool isPressed = false;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: AnimatedScale(
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeOut,
    scale: isPressed
        ? 0.96
        : (isHovered ? 1.04 : 1.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: isPressed ? 0.85 : 1.0,
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) {
                setState(() => isPressed = false);
                onTap();
              },
              onTapCancel: () => setState(() => isPressed = false),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                     color: isPressed
    ? Colors.white.withValues(alpha: 0.18)
    : (isHovered
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.10)),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isPressed
                            ? Colors.blueAccent.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: isPressed
                          ? [
                              BoxShadow(
                                color: Colors.blueAccent.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading)
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          else
                            Icon(icon, size: 40, color: Colors.blueAccent),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedAppBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const AnimatedAppBarButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  State<AnimatedAppBarButton> createState() => _AnimatedAppBarButtonState();
}

class _AnimatedAppBarButtonState extends State<AnimatedAppBarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _pressed ? 0.85 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(widget.icon, size: widget.size, color: Colors.white),
        ),
      ),
    );
  }
}
