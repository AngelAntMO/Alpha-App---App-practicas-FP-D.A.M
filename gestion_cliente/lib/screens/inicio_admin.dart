import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    _glowColorAnimation =
        ColorTween(
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

    _cardFadeAnimations = List.generate(3, (index) {
      return CurvedAnimation(
        parent: _cardController,
        curve: Interval(
          0.2 * index,
          0.6 + (0.2 * index),
          curve: Curves.easeOut,
        ),
      );
    });

    _cardSlideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            0.2 * index,
            0.6 + (0.2 * index),
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

    // pequeño delay para que entre después del logo
    Future.delayed(const Duration(milliseconds: 600), () {
      _titleController.forward();
    });
  }

  // Esto es para liberar memoria y evitar la estupenda ventana roja de error de flutter.
  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _entryController.dispose();
    _titleController.dispose();
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
          title: const Text("Panel Administrador"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          
                          AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 220 + (_waveAnimation.value * 80),
                                height: 220 + (_waveAnimation.value * 80),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.lightBlueAccent.withValues(
                                      alpha: 1 - _waveAnimation.value,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                          
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _animation,
                              _glowAnimation,
                            ]),
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (_glowColorAnimation.value ??
                                                  Colors.lightBlueAccent)
                                              .withValues(alpha: 0.5),
                                      blurRadius: _glowAnimation.value,
                                      spreadRadius: _glowAnimation.value / 2,
                                    ),
                                  ],
                                ),
                                child: Transform.scale(
                                  scale: _animation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/Icono_AlphaApp.png',
                              width: 180,
                              height: 180,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const Text(
                        "Bienvenido Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFadeAnimations[0],
                            child: SlideTransition(
                              position: _cardSlideAnimations[0],
                              child: _AdminCard(
                                icon: Icons.people,
                                title: "Usuarios",
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFadeAnimations[1],
                            child: SlideTransition(
                              position: _cardSlideAnimations[1],
                              child: _AdminCard(
                                icon: Icons.business,
                                title: "Servicios",
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: FadeTransition(
                            opacity: _cardFadeAnimations[2],
                            child: SlideTransition(
                              position: _cardSlideAnimations[2],
                              child: _AdminCard(
                                icon: Icons.settings,
                                title: "Configuración",
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _AdminCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },

      child: AnimatedScale(
        scale: isHovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),

        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(25),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            decoration: BoxDecoration(
              color: isHovering
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(25),

              border: Border.all(
                color: isHovering
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),

              boxShadow: isHovering
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: isHovering ? 75 : 65,
                  color: Colors.lightBlueAccent,
                ),

                const SizedBox(height: 20),

                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHovering ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
