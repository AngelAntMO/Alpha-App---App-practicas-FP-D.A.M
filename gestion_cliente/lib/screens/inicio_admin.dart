import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/admin_servicios.dart';
import 'package:gestion_cliente/screens/estadisticas_admin.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _glowAnimation;
  late AnimationController _glowController;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _glowColorAnimation;
  late AnimationController _cardController;
  late List<Animation<double>> _cardFadeAnimations;
  late List<Animation<Offset>> _cardSlideAnimations;
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(begin: 10, end: 25).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _glowColorAnimation = ColorTween(
      begin: const Color(0xFF2563EB),
      end: const Color(0xFF60A5FA),
    ).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardFadeAnimations = List.generate(4, (index) {
      return CurvedAnimation(
        parent: _cardController,
        curve: Interval(
          index * 0.15,
          0.55 + (index * 0.15),
          curve: Curves.easeOut,
        ),
      );
    });

    _cardSlideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.15,
            0.55 + (index * 0.15),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _cardController.forward();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _titleController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _entryController.dispose();
    _titleController.dispose();
    _cardController.dispose();
    super.dispose();
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
          title: const Text('Panel de Administrador',
              style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () async => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Logo animado ──
                  Center(
                    child: SizedBox(
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) => Container(
                              width:  220 + (_waveAnimation.value * 80),
                              height: 220 + (_waveAnimation.value * 80),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.lightBlueAccent.withValues(
                                      alpha: 1 - _waveAnimation.value),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_animation, _glowAnimation]),
                            builder: (context, child) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_glowColorAnimation.value ??
                                            Colors.lightBlueAccent)
                                        .withValues(alpha: 0.5),
                                    blurRadius:   _glowAnimation.value,
                                    spreadRadius: _glowAnimation.value / 2,
                                  ),
                                ],
                              ),
                              child: Transform.scale(
                                scale: _animation.value,
                                child: child,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/Icono_AlphaApp.png',
                              width: 170, height: 170,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Título ──
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const Center(
                        child: Column(
                          children: [
                            Text(
                              '👋',
                              style: TextStyle(fontSize: 42),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Bienvenido, Admin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Panel de administración',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Botones ──
                  FadeTransition(
                    opacity: _cardFadeAnimations[0],
                    child: SlideTransition(
                      position: _cardSlideAnimations[0],
                      child: _AdminHoverBtn(
                        icon: Icons.people,
                        text: 'Usuarios',
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _cardFadeAnimations[1],
                    child: SlideTransition(
                      position: _cardSlideAnimations[1],
                      child: _AdminHoverBtn(
                        icon: Icons.business,
                        text: 'Servicios',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GestionNegocioAdmin(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _cardFadeAnimations[2],
                    child: SlideTransition(
                      position: _cardSlideAnimations[2],
                      child: _AdminHoverBtn(
                        icon: Icons.bar_chart,
                        text: 'Estadisticas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EstadisticasAdmin(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _cardFadeAnimations[3],
                    child: SlideTransition(
                      position: _cardSlideAnimations[3],
                      child: _AdminHoverBtn(
                        icon: Icons.settings,
                        text: 'Configuración',
                        onTap: () {},
                      ),
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

// ─────────────
//  BOTÓN HOVER
// ─────────────
class _AdminHoverBtn extends StatefulWidget {
  final IconData     icon;
  final String       text;
  final VoidCallback onTap;

  const _AdminHoverBtn({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<_AdminHoverBtn> createState() => _AdminHoverBtnState();
}

class _AdminHoverBtnState extends State<_AdminHoverBtn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth > 600 ? 500 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovering = true),
          onExit:  (_) => setState(() => _hovering = false),
          child: Transform.translate(
            offset: Offset(0, _hovering ? -6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: _hovering
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale:    _hovering ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.icon,
                          color: _hovering
                              ? Colors.lightBlueAccent
                              : Colors.blueAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}